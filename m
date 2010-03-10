Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2116B0098
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 05:20:54 -0500 (EST)
Message-ID: <4B977282.40505@cs.helsinki.fi>
Date: Wed, 10 Mar 2010 12:20:50 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: 2.6.34-rc1: kernel BUG at mm/slab.c:2989!
References: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190@mail.gmail.com>
In-Reply-To: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, viro@zeniv.linux.org.uk, mingo@elte.hu, akpm@linux-foundation.org, roland@redhat.com, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

AmA(C)rico Wang kirjoitti:
> Hello, mm experts,
> 
> I triggered an mm bug today, the full backtrace is here:
> 
> http://pastebin.ca/1831436
> 
> I am using yesterday's Linus tree.
> 
> It's not easy to reproduce this, I got this very randomly.
> 
> Some related config's are:
> 
> CONFIG_SLAB=y
> CONFIG_SLABINFO=y
> # CONFIG_DEBUG_SLAB is not set
> 
> Please let me know if you need more info.

Looks like regular SLAB corruption bug to me. Can you trigget it with SLUB?

Anyway, it seems very unlikely that it's caused by the SLAB changes in 
-rc1 so I'm CC'ing scheduler and fs folks in case the oops rings a bell.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
