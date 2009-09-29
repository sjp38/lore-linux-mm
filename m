Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C35166B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 06:06:51 -0400 (EDT)
Date: Tue, 29 Sep 2009 11:28:36 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] rmap : tidy the code
In-Reply-To: <4AC16B8F.1060308@gmail.com>
Message-ID: <Pine.LNX.4.64.0909291127480.19216@sister.anvils>
References: <1254128590-27826-1-git-send-email-shijie8@gmail.com>
 <Pine.LNX.4.64.0909281131460.14446@sister.anvils>
 <8acda98c0909280430w2700826cu55f9629bafab066f@mail.gmail.com>
 <4AC16B8F.1060308@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: Nikita Danilov <danilov@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Sep 2009, Huang Shijie wrote:
> Nikita Danilov wrote:
> > I agree that adding EFAULT check into page_check_address() is better.
> > The only call-site that does not call vma_address() before
> > page_check_address() is __xip_unmap() and it explicitly BUG_ON()s on
> > the same condition.
> >
> >   
> If adding vma_address() into page_check_address() ,  it's  bad  for 
> __xip_unmap to change its code.
> __xip_unmap must fake a page to satisfy the new "page_check_address()".

You're right, I'd missed that too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
