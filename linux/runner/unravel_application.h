#ifndef FLUTTER_UNRAVEL_APPLICATION_H_
#define FLUTTER_UNRAVEL_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(UnravelApplication,
                     unravel_application,
                     UNRAVEL,
                     APPLICATION,
                     GtkApplication)

/**
 * unravel_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #UnravelApplication.
 */
UnravelApplication* unravel_application_new();

#endif  // FLUTTER_UNRAVEL_APPLICATION_H_
