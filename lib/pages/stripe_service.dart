import "dart:convert";

import "package:http/http.dart" as http;
import "package:stripe_checkout/stripe_checkout.dart";

class StripeService {
  static String secretKey =
      "sk_test_51Ny3VwSEHKhH3FY32bxUm9VTQxC0Tj6x9KMa0yx1ptceTJNeFcbKk3ctYRnelPIMzL6meY5hfJyXFkExzKhftJWG00vw93LAY9";
  static String publishableKey =
      "pk_test_51Ny3VwSEHKhH3FY3yqJwqggtMYMdXmR5akOeEtgJh0NrCFV1oiWUa5dN304jpfpR9CeHcP0LNsxOHM3M5dLc8yjQ00l3FMmZzP";

  static Future<dynamic> createCheckoutSession(lineItems) async {
    final url = Uri.parse("https://api.stripe.com/v1/checkout/sessions");

    // String lineItems = "";
    // int index = 0;

    // Convert lineItems to a formatted string
    final formattedLineItems = lineItems
        .map((item) =>
            "line_items[${lineItems.indexOf(item)}][price]=${item['price']}&line_items[${lineItems.indexOf(item)}][quantity]=${item['quantity']}")
        .join("&");

    final response = await http.post(
      url,
      body:
          'success_url=https://checkout.stripe.dev/success&mode=payment&$formattedLineItems',
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    return json.decode(response.body)["id"];
  }

  static Future<dynamic> stripePaymentCheckout(
    lineItems,
    context,
    mounted, {
    onSuccess,
    onCancel,
    onError,
  }) async {
    final String sessionId = await createCheckoutSession(lineItems);

    return redirectToCheckout(
      context: context,
      sessionId: sessionId,
      publishableKey: publishableKey,
      successUrl: "https://checkout.stripe.dev/success",
      canceledUrl: "https://checkout.stripe.dev/cancel",
    ).then((result) {
      if (mounted) {
        final text = result.when(
          redirected: () => "Redirected Succesfully",
          success: () => onSuccess(),
          canceled: () => onCancel(),
          error: (e) => onError(e),
        );

        return text;
      }
    });
  }
}
