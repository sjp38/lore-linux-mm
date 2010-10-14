Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88F3F5F0047
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 08:55:23 -0400 (EDT)
Date: Thu, 14 Oct 2010 14:55:19 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
Message-ID: <20101014125519.GB13414@basil.fritz.box>
References: <87sk0a1sq0.fsf@basil.nowhere.org>
 <20101014160217N.fujita.tomonori@lab.ntt.co.jp>
 <20101014072421.GA13414@basil.fritz.box>
 <20101014173103U.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101014173103U.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: andi@firstfloor.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> I think that at least one mainline driver in arm uses such trick but I
> can't recall the name. Better to ask on the arm mainling list. Also I
> heard that the are some out-of-tree patches about this.

I'm sure there are out of tree patches for lots of things,
but at least in terms of merging mainline functionality
use cases merged in the mainline tree are required.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
