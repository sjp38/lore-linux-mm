Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8EB716B00F1
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 03:56:26 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so468738fgg.4
        for <linux-mm@kvack.org>; Fri, 06 Mar 2009 00:56:22 -0800 (PST)
Date: Fri, 6 Mar 2009 12:03:13 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
Message-ID: <20090306090313.GB4225@x200.localdomain>
References: <49B0CAEC.80801@cn.fujitsu.com> <20090306082056.GB3450@x200.localdomain> <49B0DE89.9000401@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49B0DE89.9000401@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 04:27:53PM +0800, Li Zefan wrote:
> Alexey Dobriyan wrote:
> > On Fri, Mar 06, 2009 at 03:04:12PM +0800, Li Zefan wrote:
> >> I notice there are many places doing copy_from_user() which follows
> >> kmalloc():
> >>
> >>         dst = kmalloc(len, GFP_KERNEL);
> >>         if (!dst)
> >>                 return -ENOMEM;
> >>         if (copy_from_user(dst, src, len)) {
> >> 		kfree(dst);
> >> 		return -EFAULT
> >> 	}
> >>
> >> kmemdup_from_user() is a wrapper of the above code. With this new
> >> function, we don't have to write 'len' twice, which can lead to
> >> typos/mistakes. It also produces smaller code.
> > 
> > Name totally sucks, it mixes kernel idiom of allocation with purely
> > userspace function.
> > 
> 
> I'm not good at English, and I don't know why "kernel memory duplicated
> from user space" is so bad...
> 
> or memdup_user() ?
> 
> >> A qucik grep shows 250+ places where kmemdup_from_user() *may* be
> >> used. I'll prepare a patchset to do this conversion.
> > 
> > 250?
> > 
> 
> I just found out how many copy_from_user() following km/zalloc(), so
> not all of them are replace-able.
> 
> > Let's not add wrapper for every two lines that happen to be used
> > together.
> > 
> 
> Why not if we have good reasons? And I don't think we can call this
> "happen to" if there are 250+ of them?

Please, read through them. This "250+" number suddenly will become
like 20, because wrapper is not good enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
