Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC6A28026C
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:24:48 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id i193so474820644oib.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:24:48 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id w26si1568916otd.250.2016.09.25.15.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 15:24:47 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id n202so12519505oig.2
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:24:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
References: <20160911225425.10388-1-lstoakes@gmail.com> <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Sep 2016 15:24:47 -0700
Message-ID: <CA+55aFxsT2SJuLsf+nT56m8tMZrxoc21uSgiKwaPB7Re37=Ghw@mail.gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA balancing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Sep 25, 2016 at 1:52 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Can I have an ACK from the involved people, and I'll apply it
> directly.. Mel? Rik?

Oh well. The patch looks fine to me and I want to include it in the
rc8 release, so I'll apply it. Worst comes to worst we can revert, but
I can confirm that it's trivial to trigger the BUG_ON() without the
patch, so..

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
