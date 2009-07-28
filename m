Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 268366B004D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 01:01:43 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n6S51dxh021390
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 22:01:41 -0700
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by wpaz33.hot.corp.google.com with ESMTP id n6S51bdx011795
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 22:01:37 -0700
Received: by pzk7 with SMTP id 7so2603075pzk.9
        for <linux-mm@kvack.org>; Mon, 27 Jul 2009 22:01:36 -0700 (PDT)
Date: Mon, 27 Jul 2009 22:01:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Make it easier to catch NULL cache names
In-Reply-To: <1248749739.30993.39.camel@pasglop>
Message-ID: <alpine.DEB.2.00.0907272200520.22207@chino.kir.corp.google.com>
References: <1248745735.30993.38.camel@pasglop> <alpine.LFD.2.01.0907271951390.3186@localhost.localdomain> <1248749739.30993.39.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jul 2009, Benjamin Herrenschmidt wrote:

> > Please don't do BUG_ON() when there are alternatives.
> > 
> > In this case, something like
> > 
> > 	if (WARN_ON(!name))
> > 		return NULL;
> > 
> > would probably have worked too.
> 
> Fair enough..  I'll send a new patch.
> 

Actually needs goto err, not return NULL, to appropriately panic when 
SLAB_PANIC is set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
