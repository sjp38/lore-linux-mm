From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Selective swap out of processes
Date: Sat, 8 Sep 2007 11:45:20 +1000
References: <1188320070.11543.85.camel@bastion-laptop> <49e98fc50708301650q611f9b0fi762f9c5d8d5fae01@mail.gmail.com> <1188578404.28903.258.camel@localhost>
In-Reply-To: <1188578404.28903.258.camel@localhost>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200709081145.21097.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: jcabezas@ac.upc.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 01 September 2007 02:40, Dave Hansen wrote:
> Isn't the whole point of get_user_pages() so that the kernel doesn't
> mess with those pages, and the driver or whatever can have free reign?
>
> Seems to me that you're pinning the pages with get_user_pages(), then
> trying to get the kernel to swap them out.  Not a good idea. ;)

That's pretty much what it means... well, it is explicitly defined to simply
increment the refcount of each returned page, which happens to be
exactly what you want in this case.

Obviously your VM code that's doing the swapout has to account for
this refcount... but you'd need to do that anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
