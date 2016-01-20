Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0316F6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 18:32:38 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id cy9so12296798pac.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:32:37 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id hb8si16051734pac.55.2016.01.20.15.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 15:32:37 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id uo6so12551991pac.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:32:37 -0800 (PST)
Date: Wed, 20 Jan 2016 15:32:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm:mempolicy: skip VM_HUGETLB and VM_MIXEDMAP VMA
 for lazy mbind
In-Reply-To: <1453298848-30055-1-git-send-email-liangchen.linux@gmail.com>
Message-ID: <alpine.DEB.2.10.1601201532180.18155@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1601191424080.7346@chino.kir.corp.google.com> <1453298848-30055-1-git-send-email-liangchen.linux@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Chen <liangchen.linux@gmail.com>
Cc: linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, riel@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Gavin Guo <gavin.guo@canonical.com>

On Wed, 20 Jan 2016, Liang Chen wrote:

> VM_HUGETLB and VM_MIXEDMAP vma needs to be excluded to avoid compound
> pages being marked for migration and unexpected COWs when handling
> hugetlb fault.
> 
> Thanks to Naoya Horiguchi for reminding me on these checks.
> 
> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
