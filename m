Message-ID: <403D4D6F.6040304@cyberone.com.au>
Date: Thu, 26 Feb 2004 12:35:43 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: More vm benchmarking
References: <403C66D2.6010302@cyberone.com.au>	<20040225014757.4c79f2af.akpm@osdl.org>	<403C7181.6050103@cyberone.com.au>	<20040225020425.2c409844.akpm@osdl.org>	<20040225035043.6c536d99.akpm@osdl.org>	<403D4303.1020709@cyberone.com.au> <20040225171445.148d99a1.akpm@osdl.org>
In-Reply-To: <20040225171445.148d99a1.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>You would
>>expect ZONE_NORMAL to have more pages reclaimed from it
>>because there should be more pressure on it.
>>
>
>Why?
>
>The only things which should be special about ZONE_NORMAL which I can think
>of are:
>
>a) All the early-allocated pinned memory is sitting there and
>
>b) If you start an app which uses a lot of memory, its text pages will
>   probabyl be in ZONE_NORMAL while ZONE_DMA will contain just bss and
>   pagecache.
>

Maybe. If you're doing a heavy swapping kbuild, stuff will
be pretty randomly placed. And ZONE_NORMAL will just get
more pressure due to trying to allocate from there first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
