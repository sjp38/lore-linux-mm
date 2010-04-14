Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF5736B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 08:29:12 -0400 (EDT)
Date: Wed, 14 Apr 2010 13:32:29 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414133229.134264f0@lxorguk.ukuu.org.uk>
In-Reply-To: <8739yy9qnf.fsf@basil.nowhere.org>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
	<20100413095815.GU25756@csn.ul.ie>
	<20100413111902.GY2493@dastard>
	<20100413193428.GI25756@csn.ul.ie>
	<20100413202021.GZ13327@think>
	<877hoa9wlv.fsf@basil.nowhere.org>
	<20100414112015.GO13327@think>
	<8739yy9qnf.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> The only part of the 4K stack code that's good is the separate
> interrupt stack, but that one should be just combined with a sane 8K 
> process stack.

The reality is that if you are blowing a 4K process stack you are
probably playing russian roulette on the current 8K x86-32 stack as well
because of the non IRQ split. So it needs fixing either way

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
