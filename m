Message-Id: <3.0.6.32.20030223184931.00825e30@boo.net>
Date: Sun, 23 Feb 2003 18:49:31 -0500
From: Jason Papadopoulos <jasonp@boo.net>
Subject: [PATCH] page coloring for 2.5.62 kernel, version 1
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello again. This version of the page coloring patch implements
"stealth mode", i.e. is as minimal as possible. There are many
cleanups, and a few mods for the 2.5 series kernel.

The biggest change is that the hot/cold per-cpu lists are individually
colored now, and the patch has the effect of randomizing the cache
colors of pages pumped into the per-cpu lists. The lists are still lifo
and still favor pages just freed.

No difference in kernel compile time on the K7 system I have; I suspect
that decoupling allocation of pages from allocation of pages to processes
dilutes the effectiveness of page coloring, but all of the schemes I can
think of to enforce page coloring to processes are much more complicated
than the one used by this patch.

Patch with /proc output:

www.boo.net/~jasonp/page_color-2.5.62-20030223.patch

and without:

www.boo.net/~jasonp/page_color-2.5.62-20030223a.patch

Feedback of any sort welcome.
jasonp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
