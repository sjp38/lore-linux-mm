Subject: Query on remap_pfn_range compatibility
Message-ID: <OF3F115AC8.F271AB73-ON86256F93.005BCD86@raytheon.com>
From: Mark_H_Johnson@raytheon.com
Date: Mon, 24 Jan 2005 10:54:22 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

I read the messages on lkml from September 2004 about the introduction of
remap_pfn_range and have a question related to coding for it. What do you
recommend for driver coding to be compatible with these functions
(remap_page_range, remap_pfn_range)?

For example, I see at least two (or three) combination I need to address:
 - 2.4 (with remap_page_range) OR 2.6.x (with remap_page_range)
 - 2.6.x-mm (with remap_pfn_range)
Is there some symbol or #ifdef value I can depend on to determine which
function I should be calling (and the value to pass in)?

Thanks.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
