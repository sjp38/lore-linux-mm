Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8466B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 04:32:26 -0400 (EDT)
Message-ID: <4BCA7A26.9040208@kernel.org>
Date: Sun, 18 Apr 2010 12:19:02 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] Numa: Use Generic Per-cpu Variables for numa_*_id()
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 04/16/2010 02:29 AM, Lee Schermerhorn wrote:
> Use Generic Per cpu infrastructure for numa_*_id() V4
> 
> Series Against: 2.6.34-rc3-mmotm-100405-1609

Other than the minor nitpicks, the patchset looks great to me.
Through which tree should this be routed?  If no one else is gonna
take it, I can route it through percpu after patchset refresh.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
