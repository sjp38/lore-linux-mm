In-reply-to: <alpine.LFD.1.00.0801231248060.2803@woody.linux-foundation.org>
	(message from Linus Torvalds on Wed, 23 Jan 2008 13:00:57 -0800 (PST))
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in
 sys_msync()
References: <12010440803930-git-send-email-salikhmetov@gmail.com>  <1201044083504-git-send-email-salikhmetov@gmail.com>  <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org> <1201110066.6341.65.camel@lappy> <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
 <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231248060.2803@woody.linux-foundation.org>
Message-Id: <E1JHmxa-0004BK-6X@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 23 Jan 2008 22:16:38 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, a.p.zijlstra@chello.nl, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> So it's not horribly hard, but it's kind of a separate issue right now. 
> And while the *generic* page-writeback is easy enough to fix, I worry 
> about low-level filesystems that have their own "writepages()" 
> implementation. They could easily get that wrong.

Yeah, nasty.

How about doing it in a separate pass, similarly to
wait_on_page_writeback()?  Just instead of waiting, clean the page
tables for writeback pages.

> So right now it seems that waiting for writeback to finish is the right 
> and safe thing to do (and even so, I'm not actually willing to commit my 
> suggested patch in 2.6.24, I think this needs more thinking about)

Sure, I would have though all of this stuff is 2.6.25, but it's your
kernel... :)

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
