Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC786B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 04:03:23 -0400 (EDT)
Received: by qgez77 with SMTP id z77so32945903qge.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 01:03:23 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id k91si6667230qgf.53.2015.09.18.01.03.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 01:03:22 -0700 (PDT)
Received: by qgt47 with SMTP id 47so32761174qgt.2
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 01:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55FAB985.9060705@suse.cz>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
	<20150916135048.fbd50fac5e91244ab9731b82@gmail.com>
	<55FAB985.9060705@suse.cz>
Date: Fri, 18 Sep 2015 10:03:22 +0200
Message-ID: <CAMJBoFNmK94yPL7GkRPyeyETn8_dC+zCvd8efEH=ncgPDyuJuQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] zbud: allow PAGE_SIZE allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> I don't know how zsmalloc handles uncompressible PAGE_SIZE allocations, but
> I wouldn't expect it to be any more clever than this? So why duplicate the
> functionality in zswap and zbud? This could be handled e.g. at the zpool
> level? Or maybe just in zram, as IIRC in zswap (frontswap) it's valid just
> to reject a page and it goes to physical swap.

>From what I can see, zsmalloc just allocates pages and puts them into
a linked list. Using the beginning of a page for storing an internal
struct is zbud-specific, and so is this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
