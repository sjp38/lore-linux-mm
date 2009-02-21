Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 167D26B0095
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 12:20:10 -0500 (EST)
Message-ID: <49A036CD.6040503@cs.helsinki.fi>
Date: Sat, 21 Feb 2009 19:15:57 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] kmemcheck: add hooks for page- and sg-dma-mappings
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>	 <1235223364-2097-4-git-send-email-vegard.nossum@gmail.com>	 <49A02A61.6060909@cs.helsinki.fi> <19f34abd0902210913qe0539ebgf74c9b5e0b577786@mail.gmail.com>
In-Reply-To: <19f34abd0902210913qe0539ebgf74c9b5e0b577786@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Vegard Nossum wrote:
>> What's with the new BUG_ON() calls here?
> 
> What new BUG_ON calls? Do you need glasses?

Apparently I do!

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
