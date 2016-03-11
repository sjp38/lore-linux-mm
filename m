Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 646606B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:47:45 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id xr8so147175739lbb.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:47:45 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id al3si4094372lbc.154.2016.03.11.03.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 03:47:44 -0800 (PST)
Received: by mail-lb0-x229.google.com with SMTP id k15so153459285lbg.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:47:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <14d02da417b3941fd871566e16a164ca4d4ccabc.1457519440.git.glider@google.com>
References: <cover.1457519440.git.glider@google.com>
	<14d02da417b3941fd871566e16a164ca4d4ccabc.1457519440.git.glider@google.com>
Date: Fri, 11 Mar 2016 14:47:43 +0300
Message-ID: <CAPAsAGy3goFXhFZiAarYV3NFZHQOYQxaF324UOJrMCbaZWV7CQ@mail.gmail.com>
Subject: Re: [PATCH v5 2/7] mm, kasan: SLAB support
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-09 14:05 GMT+03:00 Alexander Potapenko <glider@google.com>:

> +struct kasan_track {
> +       u64 cpu : 6;                    /* for NR_CPUS = 64 */

What about NR_CPUS > 64 ?

> +       u64 pid : 16;                   /* 65536 processes */
> +       u64 when : 42;                  /* ~140 years */
> +};
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
