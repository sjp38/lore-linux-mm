Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5D5E66B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 07:44:37 -0400 (EDT)
Date: Wed, 11 Mar 2009 19:43:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Memory usage per memory zone
Message-ID: <20090311114353.GA759@localhost>
References: <e2dc2c680903110341g6c9644b8j87ce3b364807e37f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2dc2c680903110341g6c9644b8j87ce3b364807e37f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: jack marrow <jackmarrow2@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi jack,

On Wed, Mar 11, 2009 at 11:41:43AM +0100, jack marrow wrote:
> Hello,
> 
> I have a box where the oom-killer is killing processes due to running
> out of memory in zone_normal. I can see using slabtop that the inode

How do you know that the memory pressure on zone normal stand out alone?

> caches are using up lots of memory and guess this is the problem, so
> have cleared them using an echo to drop_caches.

It would better be backed by concrete numbers...

> 
> I would quite like to not guess though - is it possible to use slabtop
> (or any other way) to view ram usage per zone so I can pick out the
> culprit?

/proc/zoneinfo and /proc/vmstat do have some per-zone numbers.
Some of them deal with slabs.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
