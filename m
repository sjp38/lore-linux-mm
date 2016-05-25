Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81B3E828E2
	for <linux-mm@kvack.org>; Wed, 25 May 2016 18:23:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g64so46762096pfb.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 15:23:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h9si15461185pap.227.2016.05.25.15.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 15:23:20 -0700 (PDT)
Date: Wed, 25 May 2016 15:23:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use early_pfn_to_nid in
 register_page_bootmem_info_node
Message-Id: <20160525152319.fa87b4cc0b8326fef89a1b92@linux-foundation.org>
In-Reply-To: <1464210007-30930-1-git-send-email-yang.shi@linaro.org>
References: <1464210007-30930-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Wed, 25 May 2016 14:00:07 -0700 Yang Shi <yang.shi@linaro.org> wrote:

> register_page_bootmem_info_node() is invoked in mem_init(), so it will be
> called before page_alloc_init_late() if CONFIG_DEFERRED_STRUCT_PAGE_INIT
> is enabled. But, pfn_to_nid() depends on memmap which won't be fully setup
> until page_alloc_init_late() is done, so replace pfn_to_nid() by
> early_pfn_to_nid().

What are the runtime effects of this fix?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
