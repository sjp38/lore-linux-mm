Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF226B0008
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 22:58:41 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so985636pfr.6
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 19:58:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p61-v6si17437178plb.382.2018.11.11.19.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Nov 2018 19:58:40 -0800 (PST)
Date: Sun, 11 Nov 2018 19:58:38 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] ksm: allow dedup all tasks memory
Message-ID: <20181112035838.GF21824@bombadil.infradead.org>
References: <20181111212610.25213-1-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181111212610.25213-1-timofey.titovets@synesis.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Timofey Titovets <nefelim4ag@gmail.com>

On Mon, Nov 12, 2018 at 12:26:10AM +0300, Timofey Titovets wrote:
> ksm by default working only on memory that added by
> madvice().
> 
> And only way get that work on other applications:
>  - Use LD_PRELOAD and libraries
>  - Patch kernel
> 
> Lets use kernel task list in ksm_scan_thread and add logic to allow ksm
> import VMA from tasks.
> That behaviour controlled by new attribute: mode
> I try mimic hugepages attribute, so mode have two states:
>  - normal       - old default behaviour
>  - always [new] - allow ksm to get tasks vma and try working on that.
> 
> To reduce CPU load & tasklist locking time,
> ksm try import VMAs from one task per loop.
> 
> So add new attribute "mode"
> Two passible values:
>  - normal [default] - ksm use only madvice
>  - always [new]     - ksm will search vma over all processes memory and
>                       add it to the dedup list

Do you have any numbers for how much difference this change makes with
various different workloads?
