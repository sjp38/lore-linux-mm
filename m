Date: Wed, 25 Feb 2004 17:57:16 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: More vm benchmarking
Message-Id: <20040225175716.597e0008.akpm@osdl.org>
In-Reply-To: <403D4D6F.6040304@cyberone.com.au>
References: <403C66D2.6010302@cyberone.com.au>
	<20040225014757.4c79f2af.akpm@osdl.org>
	<403C7181.6050103@cyberone.com.au>
	<20040225020425.2c409844.akpm@osdl.org>
	<20040225035043.6c536d99.akpm@osdl.org>
	<403D4303.1020709@cyberone.com.au>
	<20040225171445.148d99a1.akpm@osdl.org>
	<403D4D6F.6040304@cyberone.com.au>
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
> And ZONE_NORMAL will just get
> more pressure due to trying to allocate from there first.

No, that shouldn't be the case.  Once ZONE_NORMAL hits pages_high it just
sits there doing nothing until ZONE_DMA hits pages_high too.  That's the
point at we run (now proportional) page reclaim against both zones.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
