Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 360436B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:42:24 -0400 (EDT)
Message-ID: <4DB88DAF.2010504@freescale.com>
Date: Wed, 27 Apr 2011 16:42:07 -0500
From: Timur Tabi <timur@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
References: <20110414200139.ABD98551@kernel>	 <20110414200140.CDE09A20@kernel>  <4DB88AF0.1050501@freescale.com> <1303940249.9516.366.camel@nimitz>
In-Reply-To: <1303940249.9516.366.camel@nimitz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>

Dave Hansen wrote:
>> Is there an easy way to verify that alloc_pages_exact(5MB) really does allocate
>> > only 5MB and not 8MB?

> I'm not sure why you're asking.  How do we know that the _normal_
> allocator only gives us 4k when we ask for 4k?  Well, that's just how it
> works.  If alloc_pages_exact() returns success, you know it's got the
> amount of memory that you asked for, and only that plus a bit of masking
> for page alignment.
> 
> Have you seen alloc_pages_exact() behaving in some other way?

I've never tested this part of alloc_pages_exact(), even when I wrote (the first
version of) it.  I just took it on faith that it actually did what it was
supposed to do.

-- 
Timur Tabi
Linux kernel developer at Freescale

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
