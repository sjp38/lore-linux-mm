Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA87028026C
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 16:52:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id i193so469247340oib.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 13:52:28 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id v2si11326953oib.55.2016.09.25.13.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 13:52:28 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id r126so187477093oib.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 13:52:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160925184731.GA20480@lucifer>
References: <20160911225425.10388-1-lstoakes@gmail.com> <20160925184731.GA20480@lucifer>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Sep 2016 13:52:27 -0700
Message-ID: <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA balancing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

I was kind of assuming this would go through the normal channels for
THP patches, but it's been two weeks...

Can I have an ACK from the involved people, and I'll apply it
directly.. Mel? Rik?

                   Linus

On Sun, Sep 25, 2016 at 11:47 AM, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
> Just a quick ping on this, let me know if you need anything more from me!
>
> Thanks, Lorenzo
>
> On Sun, Sep 11, 2016 at 11:54:25PM +0100, Lorenzo Stoakes wrote:
>> The NUMA balancing logic uses an arch-specific PROT_NONE page table flag defined
>> by pte_protnone() or pmd_protnone() to mark PTEs or huge page PMDs respectively
>> as requiring balancing upon a subsequent page fault. User-defined PROT_NONE
>> memory regions which also have this flag set will not normally invoke the NUMA
>> balancing code as do_page_fault() will send a segfault to the process before
>> handle_mm_fault() is even called.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
