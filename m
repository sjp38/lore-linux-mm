Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0E606900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 15:19:50 -0400 (EDT)
Received: by igjz20 with SMTP id z20so6634521igj.4
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 12:19:49 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id j79si1904954ioe.36.2015.03.10.12.19.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 12:19:48 -0700 (PDT)
Received: by iecsf10 with SMTP id sf10so26433402iec.2
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 12:19:46 -0700 (PDT)
Date: Tue, 10 Mar 2015 12:19:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: refactor zone_movable_is_highmem()
In-Reply-To: <54FE9C21.8060107@huawei.com>
Message-ID: <alpine.DEB.2.10.1503101219320.29618@chino.kir.corp.google.com>
References: <1425972055-53804-1-git-send-email-zhenzhang.zhang@huawei.com> <54FE9C21.8060107@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, iamjoonsoo.kim@lge.com, Dave Hansen <dave.hansen@intel.com>

On Tue, 10 Mar 2015, Zhang Zhen wrote:

> All callers of zone_movable_is_highmem are under #ifdef CONFIG_HIGHMEM,
> so the else branch return 0 is not needed.
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
