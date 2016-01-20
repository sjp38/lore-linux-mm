Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 463766B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 01:48:43 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ho8so204292937pac.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 22:48:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s137si53043891pfs.11.2016.01.19.22.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 22:48:42 -0800 (PST)
Date: Tue, 19 Jan 2016 22:48:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in
 split_huge_page_to_list
Message-Id: <20160119224841.8c16ea03.akpm@linux-foundation.org>
In-Reply-To: <87powwvm6b.fsf@linux.vnet.ibm.com>
References: <CACT4Y+ayDrEmn31qyoVdnq6vpSbL=XzFWPM5_Ee4GH=Waf27eA@mail.gmail.com>
	<20160118133852.GC14531@node.shutemov.name>
	<87powwvm6b.fsf@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, jmarchan@redhat.com, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Wed, 20 Jan 2016 11:15:32 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> >
> > I think this should fix the issue:
> >
> > From 10859758dadfa249616870f63c1636ec9857c501 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Mon, 18 Jan 2016 16:28:12 +0300
> > Subject: [PATCH] thp: fix interrupt unsafe locking in split_huge_page()
> >
> > split_queue_lock can be taken from interrupt context in some cases, but
> > I forgot to convert locking in split_huge_page() to interrupt-safe
> > primitives.
> >
> > Let's fix this.
> 
> Can you add the stack trace from the problem reported to the commit
> message ?

I have already done this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
