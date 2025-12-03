/*
 * Copyright (c) 2020, The Linux Foundation. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
#include <qdf_hang_event_notifier.h>
#include <qdf_notifier.h>
#include <wmi_hang_event.h>
#include <wmi_unified_priv.h>
#include <qdf_trace.h>

struct wmi_hang_data_fixed_param {
	uint16_t tlv_header; /* tlv tag and length */
	uint32_t event;
	uint32_t data;
	uint64_t time;
} qdf_packed;

#define WMI_EVT_HIST 0
#define WMI_CMD_HIST 1

static int wmi_recovery_notifier_call(struct notifier_block *block,
				      unsigned long state,
				      void *data)
{
	return NOTIFY_OK;
}

static qdf_notif_block wmi_recovery_notifier = {
	.notif_block.notifier_call = wmi_recovery_notifier_call,
};

QDF_STATUS wmi_hang_event_notifier_register(struct wmi_unified *wmi_hdl)
{
	wmi_recovery_notifier.priv_data = wmi_hdl;
	return qdf_hang_event_register_notifier(&wmi_recovery_notifier);
}

QDF_STATUS wmi_hang_event_notifier_unregister(void)
{
	return qdf_hang_event_unregister_notifier(&wmi_recovery_notifier);
}
