Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 814076B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:24:48 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id q63so187881928pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:24:48 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id af6si12583023pad.226.2016.01.19.14.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 14:24:47 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id n128so182391963pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:24:47 -0800 (PST)
Date: Tue, 19 Jan 2016 14:24:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm:mempolicy: skip VM_HUGETLB and VM_MIXEDMAP VMA for
 lazy mbind
In-Reply-To: <1453125834-16546-1-git-send-email-liangchen.linux@gmail.com>
Message-ID: <alpine.DEB.2.10.1601191424080.7346@chino.kir.corp.google.com>
References: <1453125834-16546-1-git-send-email-liangchen.linux@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Chen <liangchen.linux@gmail.com>
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, riel@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Gavin Guo <gavin.guo@canonical.com>

On Mon, 18 Jan 2016, Liang Chen wrote:

> VM_HUGETLB and VM_MIXEDMAP vma needs to be excluded to avoid compound
> pages being marked for migration and unexpected COWs when handling
> hugetlb fault.
> 
> Thanks to Naoya Horiguchi for reminding me on these checks.
> 
> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>

Acked-by: David Rientjes <rientjes@google.com>

I think it should also have

Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
