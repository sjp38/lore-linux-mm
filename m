Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 986778D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 15:59:57 -0500 (EST)
Message-ID: <4D65754B.7010608@tilera.com>
Date: Wed, 23 Feb 2011 15:59:55 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/25] tile: Fix __pte_free_tlb
References: <20110125173111.720927511@chello.nl>	 <20110125174907.220115681@chello.nl>  <4D4C63ED.6060104@tilera.com> <1297086911.13327.17.camel@laptop>
In-Reply-To: <1297086911.13327.17.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On 2/7/2011 8:55 AM, Peter Zijlstra wrote:
> On Fri, 2011-02-04 at 15:39 -0500, Chris Metcalf wrote:
>> On 1/25/2011 12:31 PM, Peter Zijlstra wrote:
>>> Tile's __pte_free_tlb() implementation makes assumptions about the
>>> generic mmu_gather implementation, cure this ;-)
>> I assume you will take this patch into your tree?  If so:
>>
>> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
> Feel free to take it yourself, this series might take a while to land..

Thanks, I took it into my tree (without the comment about the on-stack array).

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
