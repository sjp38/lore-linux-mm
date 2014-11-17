Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 33DF06B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 14:45:07 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id rp18so2440950iec.25
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 11:45:07 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id en16si56336588icb.5.2014.11.17.11.45.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Nov 2014 11:45:06 -0800 (PST)
Received: by mail-ig0-f170.google.com with SMTP id r2so2814823igi.1
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 11:45:05 -0800 (PST)
Date: Mon, 17 Nov 2014 11:45:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memory-hotplug: remove redundant call of page_to_pfn
In-Reply-To: <5461D343.60803@huawei.com>
Message-ID: <alpine.DEB.2.10.1411171144550.25623@chino.kir.corp.google.com>
References: <1415697184-26409-1-git-send-email-zhenzhang.zhang@huawei.com> <5461D343.60803@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, wangnan0@huawei.com

On Tue, 11 Nov 2014, Zhang Zhen wrote:

> The start_pfn can be obtained directly by
> phys_index << PFN_SECTION_SHIFT.
> 
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
