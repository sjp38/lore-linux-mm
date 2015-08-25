Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4F21A6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 19:33:22 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so5754397pac.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:33:22 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id hn3si35410775pac.142.2015.08.25.16.33.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 16:33:21 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so138933522pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:33:21 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:33:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] Documentation: clarify in calculating zone
 protection
In-Reply-To: <1440511291-3990-2-git-send-email-bywxiaobai@163.com>
Message-ID: <alpine.DEB.2.10.1508251633070.10653@chino.kir.corp.google.com>
References: <1440511291-3990-1-git-send-email-bywxiaobai@163.com> <1440511291-3990-2-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 25 Aug 2015, Yaowei Bai wrote:

> Every zone's protection is calculated from managed_pages not
> present_pages, to avoid misleading, correct it.
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
