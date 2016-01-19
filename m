Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 656176B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:26:27 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id n128so182411827pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:26:27 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id p7si50163442pfa.74.2016.01.19.14.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 14:26:26 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id 65so182430294pff.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:26:26 -0800 (PST)
Date: Tue, 19 Jan 2016 14:26:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: mm: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in
 split_huge_page_to_list
In-Reply-To: <20160118133852.GC14531@node.shutemov.name>
Message-ID: <alpine.DEB.2.10.1601191426070.7346@chino.kir.corp.google.com>
References: <CACT4Y+ayDrEmn31qyoVdnq6vpSbL=XzFWPM5_Ee4GH=Waf27eA@mail.gmail.com> <20160118133852.GC14531@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, jmarchan@redhat.com, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Mon, 18 Jan 2016, Kirill A. Shutemov wrote:

> From 10859758dadfa249616870f63c1636ec9857c501 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 18 Jan 2016 16:28:12 +0300
> Subject: [PATCH] thp: fix interrupt unsafe locking in split_huge_page()
> 
> split_queue_lock can be taken from interrupt context in some cases, but
> I forgot to convert locking in split_huge_page() to interrupt-safe
> primitives.
> 
> Let's fix this.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
