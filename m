Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D9F636B004D
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 17:12:23 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <681c22d4-96fb-4e15-9029-cd90956399de@default>
Date: Sun, 15 Apr 2012 14:12:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: mm code for allowing reclaim of page previously swapped but now
 clean-in-memory?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, riel@redhat.com

I'm looking for mm code/heuristics/flags where the following occurs:

This (anonymous) page was:
- previously swapped to a swap device
- then later read back in from the swap device

Now memory pressure has resulted in a need to reclaim memory so:
- this page is discovered to still be clean, i.e. it
   matches the page still on the swap device, so
- the pageframe is thus an obvious candidate for reclaim

I'd be grateful for any pointers/education...  For example,
is such a page always in the swapcache?  Is it also in the
page cache?  Is it always INactive since it was read but never
written?  What flags are set/unset?  What function or code
snippet identifies such a page and does this code need
to be protected by the swaplock or pagelock or ???
(Sorry if any of these are stupid questions...)

Purpose: I'm looking into zcache (and future KVM/memcg tmem backend)
changes to exploit a "writethrough" and/or "lazy writeback" cacheing
model for pages put into zcache via frontswap, as discussed with Andrea
and one or two others at LSF12/MM.  Either model provides more
flexibility for zcache to more effectively manage persistent pages.

Thanks!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
