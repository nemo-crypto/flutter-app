#ifndef FLUTTER_FLUTTER_STARTER_APPLICATION_H_
#define FLUTTER_FLUTTER_STARTER_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(FlutterStarterApplication,
                     flutter_starter_application,
                     FLUTTER_STARTER,
                     APPLICATION,
                     GtkApplication)

/**
 * flutter_starter_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #FlutterStarterApplication.
 */
FlutterStarterApplication* flutter_starter_application_new();

#endif  // FLUTTER_FLUTTER_STARTER_APPLICATION_H_
