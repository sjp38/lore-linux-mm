Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 70BFA6B00EE
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 03:39:38 -0500 (EST)
Date: Fri, 6 Mar 2009 00:39:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] kmemdup_from_user(): introduce
Message-Id: <20090306003900.a031a914.akpm@linux-foundation.org>
In-Reply-To: <49B0DE89.9000401@cn.fujitsu.com>
References: <49B0CAEC.80801@cn.fujitsu.com>
	<20090306082056.GB3450@x200.localdomain>
	<49B0DE89.9000401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 06 Mar 2009 16:27:53 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:

> > Let's not add wrapper for every two lines that happen to be used
> > together.
> > 
> 
> Why not if we have good reasons? And I don't think we can call this
> "happen to" if there are 250+ of them?

The change is a good one.  If a reviewer (me) sees it then you know the
code's all right and the review effort becomes less - all you need to check
is that the call site is using IS_ERR/PTR_ERR and isn't testing for
NULL.  Less code, less chance for bugs.

Plus it makes kernel text smaller.

Yes, the name is a bit cumbersome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
