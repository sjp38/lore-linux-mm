Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D14286B0008
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 20:49:31 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so7060179pgb.10
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 17:49:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 10-v6si18271707pgk.480.2018.11.12.17.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 17:49:30 -0800 (PST)
Date: Mon, 12 Nov 2018 17:49:28 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Message-ID: <20181113014928.GH21824@bombadil.infradead.org>
References: <20181112231344.7161-1-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181112231344.7161-1-timofey.titovets@synesis.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>
Cc: linux-kernel@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Tue, Nov 13, 2018 at 02:13:44AM +0300, Timofey Titovets wrote:
> Some numbers from different not madvised workloads.
> Formulas:
>   Percentage ratio = (pages_sharing - pages_shared)/pages_unshared
>   Memory saved = (pages_sharing - pages_shared)*4/1024 MiB
>   Memory used = free -h
> 
>   * Name: My working laptop
>     Description: Many different chrome/electron apps + KDE
>     Ratio: 5%
>     Saved: ~100  MiB
>     Used:  ~2000 MiB

Your _laptop_ saves 100MB of RAM?  That's extraordinary.  Essentially
that's like getting an extra 100MB of page cache for free.  Is there
any observable slowdown?  I could even see there being a speedup (due
to your working set being allowed to be 5% larger)

I am now a big fan of this patch and shall try to give it the review
that it deserves.
