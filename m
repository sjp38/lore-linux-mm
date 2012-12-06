Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0632A8D0011
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 16:37:09 -0500 (EST)
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-b31.telenor.se (Postfix) with ESMTP id 1CE38E9E17
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 22:37:07 +0100 (CET)
From: "Henrik Rydberg" <rydberg@euromail.se>
Date: Thu, 6 Dec 2012 22:39:09 +0100
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206213909.GA625@polaris.bitmath.org>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de>
 <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
 <20121206175451.GC17258@suse.de>
 <CA+55aFwDZHXf2FkWugCy4DF+mPTjxvjZH87ydhE5cuFFcJ-dJg@mail.gmail.com>
 <20121206183259.GA591@polaris.bitmath.org>
 <CA+55aFzievpA_b5p-bXwW11a89eC-ucpzKUuSqb2PNQOLrqaPg@mail.gmail.com>
 <20121206192845.GA599@polaris.bitmath.org>
 <CA+55aFy4Lv+_aPEakOJNR2F9PR=09jviT6Z70_NkWV5bSH5ABw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy4Lv+_aPEakOJNR2F9PR=09jviT6Z70_NkWV5bSH5ABw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

> There is also a
> 
>     low_pfn += pageblock_nr_pages;
>     low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
> 
> that looks suspicious for similar reasons. Maybe
> 
>     low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
> 
> instead? Although that *can* result in the same low_pfn in the end, so
> maybe that one was correct after all? I just did some grepping, no
> actual semantic analysis...

Here is a totally obscure version:

	low_pfn |= pageblock_nr_pages - 1;

It simply moves to the very end of the block, which seems to be what
was intended.

Henrik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
