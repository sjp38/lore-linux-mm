Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBH0gsFJ632960
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 19:42:58 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBH0gsVt185914
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:42:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBH0gsLD014418
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:42:54 -0700
Subject: Re: [patch] [RFC] make WANT_PAGE_VIRTUAL a config option
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0412170133560.793@scrub.home>
References: <E1Cf3bP-0002el-00@kernel.beaverton.ibm.com>
	 <Pine.LNX.4.61.0412170133560.793@scrub.home>
Content-Type: text/plain
Message-Id: <1103244171.13614.2525.camel@localhost>
Mime-Version: 1.0
Date: Thu, 16 Dec 2004 16:42:51 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, geert@linux-m68k.org, ralf@linux-mips.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-12-16 at 16:36, Roman Zippel wrote:
> On Thu, 16 Dec 2004, Dave Hansen wrote:
> > I'm working on breaking out the struct page definition into its
> > own file.  There seem to be a ton of header dependencies that
> > crop up around struct page, and I'd like to start getting rid
> > of thise.
> 
> Why do you want to move struct page into a separate file?

Circular header dependencies suck :)

I posted another patch, shortly after the one that I cc'd you on, with
the following description.  Cristoph suggested just making it
linux/page.h and maybe combining it with page-flags.h, but otherwise the
idea remains the same.  

> There are currently 24 places in the tree where struct page is
> predeclared.  However, a good number of these places also have to
> do some kind of arithmetic on it, and end up using macros because
> static inlines wouldn't have the type fully defined at
> compile-time.
> 
> But, in reality, struct page has very few dependencies on outside
> macros or functions, and doesn't really need to be a part of the
> header include mess which surrounds many of the VM headers.
> 
> So, put 'struct page' into structpage.h, along with a nasty comment
> telling everyone to keep their grubby mitts out of the file.
> 
> Now, we can use static inlines for almost any 'struct page'
> operations with no problems, and get rid of many of the
> predeclarations.


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
