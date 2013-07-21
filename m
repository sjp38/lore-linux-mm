Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5B97D6B0031
	for <linux-mm@kvack.org>; Sun, 21 Jul 2013 12:30:55 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so6234199pab.27
        for <linux-mm@kvack.org>; Sun, 21 Jul 2013 09:30:54 -0700 (PDT)
Received: from [71.84.184.93] (71-84-184-93.dhcp.mdfd.or.charter.com. [71.84.184.93])
        by mx.google.com with ESMTPSA id pv5sm34297607pac.14.2013.07.21.09.30.53
        for <linux-mm@kvack.org>
        (version=SSLv3 cipher=RC4-SHA bits=128/128);
        Sun, 21 Jul 2013 09:30:53 -0700 (PDT)
Subject: [Fwd: mmotm: swap overflow warning patch: mangled description and
 missing review tag]
From: Raymond Jennings <shentino@gmail.com>
Content-Type: multipart/mixed; boundary="=-gbivq+4PdClbf1kEEtsG"
Date: Sun, 21 Jul 2013 09:30:51 -0700
Message-ID: <1374424251.14112.5.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--=-gbivq+4PdClbf1kEEtsG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Screwed up and used the wrong domain for linux-mm.

--=-gbivq+4PdClbf1kEEtsG
Content-Disposition: inline
Content-Description: Forwarded message - mmotm: swap overflow warning
 patch: mangled description and missing review tag
Content-Type: message/rfc822

Return-Path: <shentino@gmail.com>
Received: from [71.84.184.93] (71-84-184-93.dhcp.mdfd.or.charter.com.
 [71.84.184.93]) by mx.google.com with ESMTPSA id
 eq5sm31012196pbc.15.2013.07.21.09.29.28 for <multiple recipients>
 (version=SSLv3 cipher=RC4-SHA bits=128/128); Sun, 21 Jul 2013 09:29:29
 -0700 (PDT)
Subject: mmotm: swap overflow warning patch: mangled description and
 missing review tag
From: Raymond Jennings <shentino@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Valdis Kletnieks <valdis.kletnieks@vt.edu>, Rik van Riel
 <riel@redhat.com>,  Hugh Dickins <hughd@google.com>,
 linux-kernel@vger.kernel.org, linux-mm@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 21 Jul 2013 09:29:27 -0700
Message-ID: <1374424167.14112.4.camel@localhost>
Mime-Version: 1.0
X-Mailer: Evolution 2.32.3 
Content-Transfer-Encoding: 7bit

I checked the mmotm queue and it seems that my mid-air corrections got
the patch mangled when it was saved to your mail queue, and in addition
to a missing correction of a typo in my testing log, Rik van Riel's
Reviewed-By tag vanished

http://www.ozlabs.org/~akpm/mmotm/broken-out/swap-warn-when-a-swap-area-overflows-the-maximum-size.patch

If you could fix my test transcript and properly credit Rik for
reviewing my patch before you ship it to linus I'd appreciate it.

The correctly formatted patch and description with corrections and tags
follows:
----
From: Raymond Jennings <shentino@gmail.com>
Subject: swap: warn when a swap area overflows the maximum size

It is possible to swapon a swap area that is too big for the pte width
to handle.

Presently this failure happens silently.

Instead, emit a diagnostic to warn the user.

Testing results, root prompt commands and kernel log messages:

# lvresize /dev/system/swap --size 16G
# mkswap /dev/system/swap
# swapon /dev/system/swap

Jul  7 04:27:22 warfang kernel: Adding 16777212k swap
on /dev/mapper/system-swap.  Priority:-1 extents:1 across:16777212k 

# lvresize /dev/system/swap --size 64G
# mkswap /dev/system/swap
# swapon /dev/system/swap

Jul  7 04:27:22 warfang kernel: Truncating oversized swap area, only
using 33554432k out of 67108860k
Jul  7 04:27:22 warfang kernel: Adding 33554428k swap
on /dev/mapper/system-swap.  Priority:-1 extents:1 across:33554428k 

Signed-off-by: Raymond Jennings <shentino@gmail.com>
Acked-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/swapfile.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN
mm/swapfile.c~swap-warn-when-a-swap-area-overflows-the-maximum-size
mm/swapfile.c
---
a/mm/swapfile.c~swap-warn-when-a-swap-area-overflows-the-maximum-size
+++ a/mm/swapfile.c
@@ -1953,6 +1953,12 @@ static unsigned long read_swap_header(st
 	 */
 	maxpages = swp_offset(pte_to_swp_entry(
 			swp_entry_to_pte(swp_entry(0, ~0UL)))) + 1;
+	if (swap_header->info.last_page > maxpages) {
+		printk(KERN_WARNING
+			"Truncating oversized swap area, only using %luk out of %luk\n",
+			maxpages << (PAGE_SHIFT - 10),
+			swap_header->info.last_page << (PAGE_SHIFT - 10));
+	}
 	if (maxpages > swap_header->info.last_page) {
 		maxpages = swap_header->info.last_page + 1;
 		/* p->max is an unsigned int: don't overflow it */



--=-gbivq+4PdClbf1kEEtsG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
