Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BA52C6B0255
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 19:33:37 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so66068852pac.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:33:37 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id l15si35324198pbq.113.2015.08.25.16.33.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 16:33:37 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so5760235pac.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:33:36 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:33:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm/page_alloc: change sysctl_lower_zone_reserve_ratio
 to sysctl_lowmem_reserve_ratio
In-Reply-To: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
Message-ID: <alpine.DEB.2.10.1508251633240.10653@chino.kir.corp.google.com>
References: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 25 Aug 2015, Yaowei Bai wrote:

> We use sysctl_lowmem_reserve_ratio rather than sysctl_lower_zone_reserve_ratio to
> determine how aggressive the kernel is in defending lowmem from the possibility of
> being captured into pinned user memory. To avoid misleading, correct it in some
> comments.
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
