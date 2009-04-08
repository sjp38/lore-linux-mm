Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 39EA25F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 13:29:33 -0400 (EDT)
From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] [0/16] POISON: Intro
References: <20090407509.382219156@firstfloor.org>
	<20090407221542.91cd3c42.akpm@linux-foundation.org>
	<20090408061539.GD17934@one.firstfloor.org>
Date: Wed, 08 Apr 2009 10:29:34 -0700
In-Reply-To: <20090408061539.GD17934@one.firstfloor.org> (Andi Kleen's message
	of "Wed, 8 Apr 2009 08:15:39 +0200")
Message-ID: <adafxgj6old.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

 > [1] I didn't consider that one high priority since production
 > systems with long uptime shouldn't have much free memory.

Surely there are windows after a big job exits where lots of memory
might be free.  Not sure how big those windows are in practice but it
does seem if a process using 128GB exits then it might take a while
before that memory all gets used again.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
