Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCAA6B0005
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 13:28:25 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u11-v6so12344744oif.22
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:28:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d185-v6sor7003083oif.163.2018.07.02.10.28.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 10:28:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <788aa605-94c7-f730-6ec6-0eac53cb10cf@virtuozzo.com>
References: <20180625170259.30393-1-aryabinin@virtuozzo.com>
 <20180629164932.740-1-aryabinin@virtuozzo.com> <20180629193300.0ae0f25880a800bd27952b15@linux-foundation.org>
 <788aa605-94c7-f730-6ec6-0eac53cb10cf@virtuozzo.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 2 Jul 2018 10:28:23 -0700
Message-ID: <CAPcyv4gN_f0q2a+e2-cXZoDGwKe2DfcMcHMZnf3UmyWp+dekSA@mail.gmail.com>
Subject: Re: [PATCH v2] kernel/memremap, kasan: Make ZONE_DEVICE with work
 with KASAN
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, david <david@fromorbit.com>, kasan-dev@googlegroups.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On Mon, Jul 2, 2018 at 10:22 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
[..]
> It could be possible to not unmap kasan_zero_page, just leave it there after devm_memremap_pages_release().
> But we must have some guarantee that after devm_memremap_pages()/devm_memremap_pages_release() the same
> addresses can't be reused for ordinary hotpluggable memory.

While this does not happen today we are looking to support it the
future. I.e. have userspace policy pick whether to access an address
range through a device-file mmap, or treat it as typical memory.
