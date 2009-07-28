Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 04E536B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 22:52:36 -0400 (EDT)
Date: Mon, 27 Jul 2009 19:52:35 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm: Make it easier to catch NULL cache names
In-Reply-To: <1248745735.30993.38.camel@pasglop>
Message-ID: <alpine.LFD.2.01.0907271951390.3186@localhost.localdomain>
References: <1248745735.30993.38.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Tue, 28 Jul 2009, Benjamin Herrenschmidt wrote:
>
> Right now, if you inadvertently pass NULL to kmem_cache_create() at boot
> time, it crashes much later after boot somewhere deep inside sysfs which
> makes it very non obvious to figure out what's going on.

Please don't do BUG_ON() when there are alternatives.

In this case, something like

	if (WARN_ON(!name))
		return NULL;

would probably have worked too.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
