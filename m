Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C5B456B0037
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:19:22 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so10002748pdj.13
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 12:19:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id cb4si6570355pbc.280.2014.04.01.12.19.21
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 12:19:21 -0700 (PDT)
Date: Tue, 1 Apr 2014 12:19:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Message-Id: <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org>
In-Reply-To: <533A5CB1.1@jp.fujitsu.com>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	<20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	<20140331170546.3b3e72f0.akpm@linux-foundation.org>
	<533A5CB1.1@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

On Tue, 01 Apr 2014 15:29:05 +0900 Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >
> > So their system will act as if they had set SHMMAX=enormous.  What
> > problems could that cause?
> >
> >
> > Look.  The 32M thing is causing problems.  Arbitrarily increasing the
> > arbitrary 32M to an arbitrary 128M won't fix anything - we still have
> > the problem.  Think bigger, please: how can we make this problem go
> > away for ever?
> >
> 
> Our middleware engineers has been complaining about this sysctl limit.
> System administrator need to calculate required sysctl value by making sum
> of all planned middlewares, and middleware provider needs to write "please
> calculate systcl param by....." in their installation manuals.

Why aren't people just setting the sysctl to a petabyte?  What problems
would that lead to?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
