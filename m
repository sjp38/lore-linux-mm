Date: Wed, 25 Feb 2004 17:14:45 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: More vm benchmarking
Message-Id: <20040225171445.148d99a1.akpm@osdl.org>
In-Reply-To: <403D4303.1020709@cyberone.com.au>
References: <403C66D2.6010302@cyberone.com.au>
	<20040225014757.4c79f2af.akpm@osdl.org>
	<403C7181.6050103@cyberone.com.au>
	<20040225020425.2c409844.akpm@osdl.org>
	<20040225035043.6c536d99.akpm@osdl.org>
	<403D4303.1020709@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> You would
> expect ZONE_NORMAL to have more pages reclaimed from it
> because there should be more pressure on it.

Why?

The only things which should be special about ZONE_NORMAL which I can think
of are:

a) All the early-allocated pinned memory is sitting there and

b) If you start an app which uses a lot of memory, its text pages will
   probabyl be in ZONE_NORMAL while ZONE_DMA will contain just bss and
   pagecache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
