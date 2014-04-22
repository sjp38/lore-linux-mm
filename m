Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 376FD6B0073
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:19:08 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id b6so5195300yha.30
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:19:07 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id q49si41855675yhe.34.2014.04.22.11.19.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 11:19:07 -0700 (PDT)
Message-ID: <1398190745.2473.10.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 3/4] ipc/shm.c: check for integer overflow during shmget.
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 22 Apr 2014 11:19:05 -0700
In-Reply-To: <1398090397-2397-4-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-4-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Mon, 2014-04-21 at 16:26 +0200, Manfred Spraul wrote:
> SHMMAX is the upper limit for the size of a shared memory segment,
> counted in bytes. The actual allocation is that size, rounded up to
> the next full page.
> Add a check that prevents the creation of segments where the
> rounded up size causes an integer overflow.
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>

Acked-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
