Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF0D6B004D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 19:46:42 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id n8LNki1i021869
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 16:46:44 -0700
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz24.hot.corp.google.com with ESMTP id n8LNjlQG001810
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 16:46:41 -0700
Received: by pzk12 with SMTP id 12so2662866pzk.10
        for <linux-mm@kvack.org>; Mon, 21 Sep 2009 16:46:41 -0700 (PDT)
Date: Mon, 21 Sep 2009 16:46:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH] remove duplicate asm/mman.h files
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3E29CC3F1@orsmsx505.amr.corp.intel.com>
Message-ID: <alpine.DEB.1.00.0909211638001.2388@chino.kir.corp.google.com>
References: <cover.1251197514.git.ebmunson@us.ibm.com> <200909181848.42192.arnd@arndb.de> <alpine.DEB.1.00.0909181236190.27556@chino.kir.corp.google.com> <200909211031.25369.arnd@arndb.de> <alpine.DEB.1.00.0909210208180.16086@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0909211258570.7831@sister.anvils> <alpine.DEB.1.00.0909211553000.30561@chino.kir.corp.google.com> <57C9024A16AD2D4C97DC78E552063EA3E29CC3F1@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, Randy Dunlap <randy.dunlap@oracle.com>, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Ulrich Drepper <drepper@redhat.com>, Alan Cox <alan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Sep 2009, Luck, Tony wrote:

> >> Is it perhaps the case that some UNIX on ia64 does implement MAP_GROWSUP,
> >> and these numbers in the Linux ia64 mman.h have been chosen to match that
> >> reference implementation?  Tony will know.  But I wonder if you'd do
> >> better at least to leave a MAP_GROWSUP comment on that line, so that
> >> somebody doesn't go and reuse the empty slot later on.
> >> 
> >
> > Reserving the bit from future use by adding a comment may be helpful, but 
> > then let's do it for MAP_GROWSDOWN too.
> 
> Tony can only speculate because this bit has been in asm/mman.h
> since before I started working on Linux (it is in the 2.4.0
> version ... which is roughly when I started ... and long before
> I was responsible for it).
> 
> Perhaps it was assumed that it would be useful?  Linux/ia64 does
> use upwardly growing memory areas (the h/w register stack engine
> saves "stack" registers to an area that grows upwards).
> 
> But since we have survived this long without it actually being
> implemented, it may be true that we don't really need it after
> all.
> 

glibc notes that both MAP_GROWSUP and MAP_GROWSDOWN are specific to Linux,
yet they don't functionally do anything.  While it may be true that 
there's no cost associated with keeping them around, I also think 
exporting such flags to userspace may give developers the belief that the 
implementation actually respects them when they're passed.

Ulrich wanted to do this last year but it appears to have been dropped.

Unless there's a convincing argument in the other direction, I don't see 
why they both can't just be removed and their bits reserved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
