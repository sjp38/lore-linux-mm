Date: Fri, 12 May 2000 09:50:54 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: RE: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <B83C33A4F7B6D311A3CA00805F85FBB863C59E@ems2.glam.ac.uk>
Message-ID: <Pine.LNX.4.21.0005112053430.1652-100000@inspiron>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jones D (ISaCS)" <djones2@glam.ac.uk>
Cc: 'Rik van Riel' <riel@conectiva.com.br>, Simon Kirby <sim@stormix.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 11 May 2000, Jones D (ISaCS) wrote:

>As I've been playing with invalidate_inode_pages for the last few
>days, this section of Andrea's classzone diff caught my eye.
>
>I noticed that in Andrea's version, if a page is locked, then it is just
>ignored, and never freed.  He reduced the complexity of the function, and

Note that the official kernel clearly ignores it too so I'm not
reinserting any bug there but only avoiding dropping performance for no
good reason and that's why I intentionally backed out such a recent
change.

To avoiding ignoring it you should wait_on_page() (you have no other way)
and according to Trond we can't do that because the caller doesn't handle
a blocking function.

Your patch ignores locked pages too from within
invalidate_inode_pages() as far I can tell.

Andrea




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
