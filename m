Message-ID: <3D2D10BC.B9DC2165@opersys.com>
Date: Thu, 11 Jul 2002 00:59:40 -0400
From: Karim Yaghmour <karim@opersys.com>
Reply-To: karim@opersys.com
MIME-Version: 1.0
Subject: Re: Enhanced profiling support (was Re: vm lock contention reduction)
References: <OFF41DACAC.FEED90BA-ON80256BF2.004DC147@portsmouth.uk.ibm.com> <3D2C9972.BB3DA772@opersys.com> <20020710214157.GD1342@dualathlon.random> <3D2D0DE0.F9D75703@opersys.com>
Content-Type: multipart/mixed;
 boundary="------------A2E70DCE1D3BB0BBB5822E59"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Richard J Moore <richardj_moore@uk.ibm.com>, John Levon <movement@marcelothewonderpenguin.com>, Andrew Morton <akpm@zip.com.au>, bob <bob@watson.ibm.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, mjbligh@linux.ibm.com, John Levon <moz@compsoc.man.ac.uk>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------A2E70DCE1D3BB0BBB5822E59
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Sorry, the attachment never made it ...

===================================================
                 Karim Yaghmour
               karim@opersys.com
      Embedded and Real-Time Linux Expert
===================================================
--------------A2E70DCE1D3BB0BBB5822E59
Content-Type: text/plain; charset=us-ascii;
 name="example.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="example.c"

/* Example usage of custom event API */

#define MODULE

#if 0
#define CONFIG_TRACE
#endif

#include <linux/config.h>
#include <linux/module.h>
#include <linux/trace.h>
#include <asm/string.h>

struct delta_event
{
  int   an_int;
  char  a_char;
};

static int alpha_id, omega_id, theta_id, delta_id, rho_id;

int init_module(void)
{
  uint8_t a_byte;
  char a_char;
  int an_int;
  int a_hex;
  char* a_string = "We are initializing the module";
  struct delta_event a_delta_event;

  /* Create events */
  alpha_id = trace_create_event("Alpha",
				"Number %d, String %s, Hex %08X",
				CUSTOM_EVENT_FORMAT_TYPE_STR,
				NULL);
  omega_id = trace_create_event("Omega",
				"Number %d, Char %c",
				CUSTOM_EVENT_FORMAT_TYPE_STR,
				NULL);
  theta_id = trace_create_event("Theta",
				"Plain string",
				CUSTOM_EVENT_FORMAT_TYPE_STR,
				NULL);
  delta_id = trace_create_event("Delta",
				NULL,
				CUSTOM_EVENT_FORMAT_TYPE_HEX,
				NULL);
  rho_id = trace_create_event("Rho",
			      NULL,
			      CUSTOM_EVENT_FORMAT_TYPE_HEX,
			      NULL);

  /* Trace events */
  an_int = 1;
  a_hex = 0xFFFFAAAA;
  trace_std_formatted_event(alpha_id, an_int, a_string, a_hex);
  an_int = 25;
  a_char = 'c';
  trace_std_formatted_event(omega_id, an_int, a_char);
  trace_std_formatted_event(theta_id);
  memset(&a_delta_event, 0, sizeof(a_delta_event));
  trace_raw_event(delta_id, sizeof(a_delta_event), &a_delta_event);
  a_byte = 0x12;
  trace_raw_event(rho_id, sizeof(a_byte), &a_byte);

  return 0;
}

void cleanup_module(void)
{
  uint8_t a_byte;
  char a_char;
  int an_int;
  int a_hex;
  char* a_string = "We are initializing the module";
  struct delta_event a_delta_event;

  /* Trace events */
  an_int = 324;
  a_hex = 0xABCDEF10;
  trace_std_formatted_event(alpha_id, an_int, a_string, a_hex);
  an_int = 789;
  a_char = 's';
  trace_std_formatted_event(omega_id, an_int, a_char);
  trace_std_formatted_event(theta_id);
  memset(&a_delta_event, 0xFF, sizeof(a_delta_event));
  trace_raw_event(delta_id, sizeof(a_delta_event), &a_delta_event);
  a_byte = 0xA4;
  trace_raw_event(rho_id, sizeof(a_byte), &a_byte);

  /* Destroy the events created */
  trace_destroy_event(alpha_id);
  trace_destroy_event(omega_id);
  trace_destroy_event(theta_id);
  trace_destroy_event(delta_id);
  trace_destroy_event(rho_id);
}


--------------A2E70DCE1D3BB0BBB5822E59--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
