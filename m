Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB6A6B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 03:21:27 -0400 (EDT)
Received: by obvd1 with SMTP id d1so65986620obv.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 00:21:26 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id m2si1127841obq.13.2015.04.01.00.21.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 00:21:26 -0700 (PDT)
Received: by obbgh1 with SMTP id gh1so62786498obb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 00:21:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150331163808.6ffa50f3140b50828bd5dba8@linux-foundation.org>
References: <1427562483-29839-1-git-send-email-kuleshovmail@gmail.com>
	<20150331163808.6ffa50f3140b50828bd5dba8@linux-foundation.org>
Date: Wed, 1 Apr 2015 13:21:25 +0600
Message-ID: <CANCZXo52sHS_2QP=mSkPayqo5A02DzN9j=m3ZQN++4v9GcTu0g@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: add debug output for the memblock_add
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Philipp Hachtmann <phacht@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Catalin Marinas <catalin.marinas@arm.com>, Emil Medve <Emilian.Medve@freescale.com>, Akinobu Mita <akinobu.mita@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

2015-04-01 5:38 GMT+06:00 Andrew Morton <akpm@linux-foundation.org>:
> On Sat, 28 Mar 2015 23:08:03 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:
>
> I guess this should be "memblock_add:".  That's what
> memblock_reserve_region() does?
>
> --- a/mm/memblock.c~mm-memblock-add-debug-output-for-the-memblock_add-fix
> +++ a/mm/memblock.c
> @@ -587,7 +587,7 @@ static int __init_memblock memblock_add_
>  {
>         struct memblock_type *_rgn = &memblock.memory;
>
> -       memblock_dbg("memblock_memory: [%#016llx-%#016llx] flags %#02lx %pF\n",
> +       memblock_dbg("memblock_add: [%#016llx-%#016llx] flags %#02lx %pF\n",
>                      (unsigned long long)base,
>                      (unsigned long long)base + size - 1,
>                      flags, (void *)_RET_IP_);
> _
>

Yes, it is much cleaner. Thank you Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
