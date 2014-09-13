Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 18ABD6B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 20:09:22 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so2381289pab.31
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 17:09:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qa1si10570185pbb.158.2014.09.12.17.09.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 17:09:21 -0700 (PDT)
Date: Fri, 12 Sep 2014 17:09:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/6] mm/balloon_compaction: fixes and cleanups
Message-Id: <20140912170919.da0719f24020dc2c4a9ae0a7@linux-foundation.org>
In-Reply-To: <20140830163834.29066.98205.stgit@zurg>
References: <20140830163834.29066.98205.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, 30 Aug 2014 20:41:06 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> I've checked compilation of linux-next/x86 for allnoconfig, defconfig and
> defconfig + kvmconfig + virtio-balloon with and without balloon-compaction.
> For stable kernels first three patches should be enough.
> 
> changes since v1:
> 
> mm/balloon_compaction: ignore anonymous pages
> * no changes
> 
> mm/balloon_compaction: keep ballooned pages away from normal migration path
> * fix compilation without CONFIG_BALLOON_COMPACTION
> 
> mm/balloon_compaction: isolate balloon pages without lru_lock
> * no changes
> 
> mm: introduce common page state for ballooned memory
> * move __Set/ClearPageBalloon into linux/mm.h
> * remove inc/dec_zone_page_state from __Set/ClearPageBalloon
> 
> mm/balloon_compaction: use common page ballooning
> * call inc/dec_zone_page_state from balloon_page_insert/delete
> 
> mm/balloon_compaction: general cleanup
> * fix compilation without CONFIG_MIGRATION
> * fix compilation without CONFIG_BALLOON_COMPACTION
> 

The patch "selftests/vm/transhuge-stress: stress test for memory
compaction" has silently and mysteriously vanished?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
