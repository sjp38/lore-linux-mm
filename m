Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DC0336B00EF
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 03:50:42 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so468199fgg.4
        for <linux-mm@kvack.org>; Fri, 06 Mar 2009 00:50:41 -0800 (PST)
Date: Fri, 6 Mar 2009 11:57:31 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
Message-ID: <20090306085731.GA4225@x200.localdomain>
References: <49B0CAEC.80801@cn.fujitsu.com> <20090306082056.GB3450@x200.localdomain> <49B0DE89.9000401@cn.fujitsu.com> <20090306003900.a031a914.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090306003900.a031a914.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 12:39:00AM -0800, Andrew Morton wrote:
> On Fri, 06 Mar 2009 16:27:53 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > > Let's not add wrapper for every two lines that happen to be used
> > > together.
> > > 
> > 
> > Why not if we have good reasons? And I don't think we can call this
> > "happen to" if there are 250+ of them?
> 
> The change is a good one.  If a reviewer (me) sees it then you know the
> code's all right and the review effort becomes less - all you need to check
> is that the call site is using IS_ERR/PTR_ERR and isn't testing for
> NULL.  Less code, less chance for bugs.
> 
> Plus it makes kernel text smaller.
> 
> Yes, the name is a bit cumbersome.

Some do NUL-termination afterwards and allocate "len + 1", but copy "len".
Some don't care.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
