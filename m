Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E1DF96B004A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 12:21:22 -0400 (EDT)
Date: Fri, 15 Jul 2011 09:21:11 -0700 (PDT)
Message-Id: <20110715.092111.70925645362970092.davem@davemloft.net>
Subject: Re: [PATCH 0/4] mm, sparc64: Implement gup_fast()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20110713153348.b68b4196.akpm@linux-foundation.org>
References: <20110712122608.938583937@chello.nl>
	<1310474531.14978.29.camel@twins>
	<20110713153348.b68b4196.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 13 Jul 2011 15:33:48 -0700

> On Tue, 12 Jul 2011 14:42:11 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
>> On Tue, 2011-07-12 at 14:26 +0200, Peter Zijlstra wrote:
>> > With the recent mmu_gather changes that included generic RCU freeing of
>> > page-tables, it is now quite straight forward to implement gup_fast() on
>> > sparc64.
>> > 
>> > Andrew, please consider merging these patches.
>> 
>> Gah, quilt-mail ate all the From: headers again.. all 4 patches are in
>> fact written by davem. Do you want a resend?
> 
> I have an editor ;)
> 
> I expect these would get more (ie: non-zero) testing if they were
> merged via Dave's tree?

It's actually easier if you merge these in for me Andrew, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
