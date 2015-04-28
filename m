Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id A09D86B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:07:07 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so105023955igb.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:07:07 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id p128si19768584ioe.59.2015.04.28.16.07.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:07:07 -0700 (PDT)
Received: by iebrs15 with SMTP id rs15so30555722ieb.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:07:07 -0700 (PDT)
Date: Tue, 28 Apr 2015 16:07:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb: reduce arch dependent code about
 hugetlb_prefault_arch_hook
In-Reply-To: <553B0D57.2090108@huawei.com>
Message-ID: <alpine.DEB.2.10.1504281606520.10203@chino.kir.corp.google.com>
References: <1429933043-56833-1-git-send-email-zhenzhang.zhang@huawei.com> <553B0D57.2090108@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nyc@holomorphy.com, anthony.iliopoulos@huawei.com, tony.luck@intel.com, Dave Hansen <dave.hansen@intel.com>, steve.capper@linaro.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Sat, 25 Apr 2015, Zhang Zhen wrote:

> Currently we have many duplicates in definitions of hugetlb_prefault_arch_hook.
> In all architectures this function is empty.
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
