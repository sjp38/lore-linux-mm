Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A646A6B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 15:12:20 -0400 (EDT)
Date: Thu, 13 May 2010 12:11:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] cpuset,mm: fix no node to alloc memory when
 changing cpuset's mems - fix2
Message-Id: <20100513121123.e105ac97.akpm@linux-foundation.org>
In-Reply-To: <4BEB9941.7040609@cn.fujitsu.com>
References: <4BEA56D3.6040705@cn.fujitsu.com>
	<20100512003246.9f0ee03c.akpm@linux-foundation.org>
	<4BEA6E3D.10503@cn.fujitsu.com>
	<20100512104817.beeee3b5.akpm@linux-foundation.org>
	<4BEB9941.7040609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 May 2010 14:16:33 +0800
Miao Xie <miaox@cn.fujitsu.com> wrote:

> > 
> > The code you have at present is fairly similar to sequence locks.  I
> > wonder if there's some way of (ab)using sequence locks for this. 
> > seqlocks don't have lockdep support either...
> > 
> 
> We can't use sequence locks here, because the read-side may read the data
> in changing, but it can't put off cleaning the old bits.

I don't understand that sentence.  Can you expand on it please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
