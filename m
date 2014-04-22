Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8C15E6B0072
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:18:56 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 131so4849779ykp.40
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:18:56 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id q56si41844404yhi.56.2014.04.22.11.18.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 11:18:55 -0700 (PDT)
Message-ID: <1398190732.2473.9.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 2/4] ipc/shm.c: check for overflows of shm_tot
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 22 Apr 2014 11:18:52 -0700
In-Reply-To: <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Mon, 2014-04-21 at 16:26 +0200, Manfred Spraul wrote:
> shm_tot counts the total number of pages used by shm segments.
> 
> If SHMALL is ULONG_MAX (or nearly ULONG_MAX), then the number
> can overflow.  Subsequent calls to shmctl(,SHM_INFO,) would return
> wrong values for shm_tot.
> 
> The patch adds a detection for overflows.
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>

Acked-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
