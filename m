Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BD9116B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 09:55:37 -0500 (EST)
Date: Wed, 11 Feb 2009 15:55:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Using module private memory to simulate microkernel's memory
	protection
Message-ID: <20090211145525.GB10525@elte.hu>
References: <a5f59d880902100542x7243b13fuf40e7dd21faf7d7a@mail.gmail.com> <20090210141405.GA16147@elte.hu> <a5f59d880902110604g40cf17b5w92431f60e6f16fa4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5f59d880902110604g40cf17b5w92431f60e6f16fa4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pengfei Hu <hpfei.cn@gmail.com>
Cc: Vegard Nossum <vegard.nossum@gmail.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Pengfei Hu <hpfei.cn@gmail.com> wrote:

> >
> > Hm, are you aware of the kmemcheck project?
> >
> >        Ingo
> >
> 
> Frankly, I only know this project's name. Just when I nearly finished
> this patch, I browsed http://git.kernel.org/ first time. I am only a
> beginner in Linux kernel. Maybe I should first discuss before write
> code. But I think it is not too late.
> 
> Can you tell me more about this project? I realy appreciate it.

Sure:

  http://tinyurl.com/cstjhb

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
