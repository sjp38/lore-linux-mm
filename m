Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6917C6B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 19:57:59 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2329643pab.29
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 16:57:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id jd9si10611696pbd.114.2014.09.12.16.57.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 16:57:58 -0700 (PDT)
Date: Fri, 12 Sep 2014 16:57:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 5/6] mm/balloon_compaction: use common page
 ballooning
Message-Id: <20140912165756.b5c7cb78b8280b4347048e02@linux-foundation.org>
In-Reply-To: <20140830164123.29066.26554.stgit@zurg>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164123.29066.26554.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, 30 Aug 2014 20:41:23 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> This patch replaces checking AS_BALLOON_MAP in page->mapping->flags
> with PageBalloon which is stored directly in the struct page.
> All code of balloon_compaction now under CONFIG_MEMORY_BALLOON.

argh, now the bogus Kconfig/Makefile changes get removed again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
