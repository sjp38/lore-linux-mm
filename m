Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 79A636B00E9
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 03:14:07 -0500 (EST)
Received: by fxm18 with SMTP id 18so256374fxm.38
        for <linux-mm@kvack.org>; Fri, 06 Mar 2009 00:14:05 -0800 (PST)
Date: Fri, 6 Mar 2009 11:20:56 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
Message-ID: <20090306082056.GB3450@x200.localdomain>
References: <49B0CAEC.80801@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49B0CAEC.80801@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 03:04:12PM +0800, Li Zefan wrote:
> I notice there are many places doing copy_from_user() which follows
> kmalloc():
> 
>         dst = kmalloc(len, GFP_KERNEL);
>         if (!dst)
>                 return -ENOMEM;
>         if (copy_from_user(dst, src, len)) {
> 		kfree(dst);
> 		return -EFAULT
> 	}
> 
> kmemdup_from_user() is a wrapper of the above code. With this new
> function, we don't have to write 'len' twice, which can lead to
> typos/mistakes. It also produces smaller code.

Name totally sucks, it mixes kernel idiom of allocation with purely
userspace function.

> A qucik grep shows 250+ places where kmemdup_from_user() *may* be
> used. I'll prepare a patchset to do this conversion.

250?

Let's not add wrapper for every two lines that happen to be used
together.

BTW, can we drop strstarts() and kzfree() on the same reasoning?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
