Message-ID: <484FBFB7.4070506@firstfloor.org>
Date: Wed, 11 Jun 2008 14:06:15 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
References: <20080606180506.081f686a.akpm@linux-foundation.org>	<20080608163413.08d46427@bree.surriel.com>	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>	<20080608173244.0ac4ad9b@bree.surriel.com>	<20080608162208.a2683a6c.akpm@linux-foundation.org>	<20080608193420.2a9cc030@bree.surriel.com>	<20080608165434.67c87e5c.akpm@linux-foundation.org>	<Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>	<20080610153702.4019e042@cuia.bos.redhat.com>	<20080610143334.c53d7d8a.akpm@linux-foundation.org>	<20080611050914.GA27488@linux-sh.org> <20080610231642.6b4b5a53.akpm@linux-foundation.org>
In-Reply-To: <20080610231642.6b4b5a53.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, Rik van Riel <riel@redhat.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, Ingo Molnar <mingo@elte.hu>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

> Andi has suggested that we can remove the node-ID encoding from
> page.flags on x86 because that info is available elsewhere, although a
> bit more slowly.
> 
> <looks at page_zone(), wonders whether we care about performance anyway>

It would be just pfn_to_nid(page_pfn(page)) for 32bit && CONFIG_NUMA.
-sh should have that too.

Only trouble is that it needs some reordering because right now page_pfn
is not defined early enough.

> There wouldn't be much point in doing that unless we did it for all
> 32-bit architectures.  How much trouble would it cause sh?

Probably very little from a quick look at the source.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
