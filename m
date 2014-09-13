Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6FAAA6B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 20:04:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so2218006pde.26
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 17:04:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bn13si10743552pdb.59.2014.09.12.17.04.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 17:04:06 -0700 (PDT)
Date: Fri, 12 Sep 2014 17:04:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 6/6] mm/balloon_compaction: general cleanup
Message-Id: <20140912170404.f14663cc823691cab36bf793@linux-foundation.org>
In-Reply-To: <20140830164127.29066.99498.stgit@zurg>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164127.29066.99498.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, 30 Aug 2014 20:41:27 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> * move special branch for balloon migraion into migrate_pages
> * remove special mapping for balloon and its flag AS_BALLOON_MAP
> * embed struct balloon_dev_info into struct virtio_balloon
> * cleanup balloon_page_dequeue, kill balloon_page_free

Not sure what's going on here - your include/linux/balloon_compaction.h
seems significantly different from mine.

I think I'll just drop this patch - it's quite inconvenient to have a
large "general cleanup" coming after a stack of significant functional
changes.  It makes review, debug, fix, merge and reversion harder. 
Let's worry about it later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
