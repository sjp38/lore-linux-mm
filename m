Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF426B0253
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 12:01:13 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id xr8so116130925lbb.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 09:01:12 -0800 (PST)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id l16si2262448lfl.202.2016.03.10.09.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 09:01:10 -0800 (PST)
Received: by mail-lb0-x234.google.com with SMTP id x1so120877032lbj.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 09:01:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160309122306.6bf0562071d06cf16bd916f4@linux-foundation.org>
References: <cover.1457519440.git.glider@google.com>
	<20160309122306.6bf0562071d06cf16bd916f4@linux-foundation.org>
Date: Thu, 10 Mar 2016 20:01:10 +0300
Message-ID: <CAPAsAGw2Z2tVuwkcmG03Sg9AE-vvx3G4tZgCQprCTzWXMEq_Rw@mail.gmail.com>
Subject: Re: [PATCH v5 0/7] SLAB support for KASAN
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-09 23:23 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
> On Wed,  9 Mar 2016 12:10:13 +0100 Alexander Potapenko <glider@google.com> wrote:
>
>> This patch set implements SLAB support for KASAN
>
> I'll queue all this up for some testing.  I'm undecided about feeding
> it into 4.5 - it is very late.  I'll be interested in advice from
> others on this...
>

You mean 4.6 of course. I  we shoudn't rush with this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
