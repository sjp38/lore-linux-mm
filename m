Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9036B0071
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:18:41 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id vb8so4863482obc.15
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:18:40 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id kk10si32135194obb.68.2014.04.22.11.18.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 11:18:39 -0700 (PDT)
Message-ID: <1398190717.2473.8.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 1/4] ipc/shm.c: check for ulong overflows in shmat
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 22 Apr 2014 11:18:37 -0700
In-Reply-To: <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Mon, 2014-04-21 at 16:26 +0200, Manfred Spraul wrote:
> find_vma_intersection does not work as intended if addr+size overflows.
> The patch adds a manual check before the call to find_vma_intersection.
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>

Acked-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
