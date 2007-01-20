Received: by wr-out-0506.google.com with SMTP id i31so575405wra
        for <linux-mm@kvack.org>; Fri, 19 Jan 2007 18:42:17 -0800 (PST)
Message-ID: <8bd0f97a0701191835y49a61e7jb65a3b63f906ca56@mail.gmail.com>
Date: Fri, 19 Jan 2007 21:35:43 -0500
From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
In-Reply-To: <45B17D6D.2030004@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
	 <45B0DB45.4070004@linux.vnet.ibm.com>
	 <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>
	 <45B112B6.9060806@linux.vnet.ibm.com>
	 <6d6a94c50701191804m79c70afdo1e664a072f928b9e@mail.gmail.com>
	 <45B17D6D.2030004@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>
List-ID: <linux-mm.kvack.org>

On 1/19/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Luckily, there are actually good, robust solutions for your higher
> order allocation problem. Do higher order allocations at boot time,
> modifiy userspace applications, or set up otherwise-unused, or easily
> reclaimable reserve pools for higher order allocations. I don't
> understand why you are so resistant to all of these approaches?

in a nutshell ...

the idea is to try and generalize these things

your approach involves tweaking each end solution to maximize the performance

our approach is to teach the kernel some more tricks so that each
solution need not be tweaked

these are at obvious odds as they tackle the problem by going in
pretty much opposite directions ... yours leads to a tighter system in
the end, but ours leads to much more rapid development and deployment
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
