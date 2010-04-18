Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9E86B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 04:32:27 -0400 (EDT)
Message-ID: <4BCA74D8.3030503@kernel.org>
Date: Sun, 18 Apr 2010 11:56:24 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] numa:  x86_64:  use generic percpu var numa_node_id()
 implementation
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain> <20100415173003.8801.48519.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.1004161144350.8664@router.home>
In-Reply-To: <alpine.DEB.2.00.1004161144350.8664@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 04/17/2010 01:46 AM, Christoph Lameter wrote:
> Maybe provide a generic function to set the node for cpu X?

Yeap, seconded.  Also, why not use numa_node_id() in
common.c::cpu_init()?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
