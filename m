Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5320B6B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:23:37 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o8FDNSD9028727
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:23:28 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8FDNX921040386
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:23:33 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8FDNXLS017843
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:23:33 +1000
Date: Wed, 15 Sep 2010 22:53:24 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100915225324.60280a50@lilo>
In-Reply-To: <20100915081653.GA16406@elte.hu>
References: <20100915104855.41de3ebf@lilo>
	<20100915080235.GA13152@elte.hu>
	<20100915081653.GA16406@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 10:16:53 +0200
Ingo Molnar <mingo@elte.hu> wrote:
> 
> btw., how does OpenMPI signal the target tasks that something
> happened to their address space - is there some pipe/socket
> side-channel, or perhaps purely based on flags in the modified memory
> areas, which are polled?

The shared memory btl signals through shared memory, though when
threading is enabled (I think its mostly used with threading support
disabled) in OpenMPI there is also signalling done through a pipe.

Regards,

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
