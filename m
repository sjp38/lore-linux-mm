Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E19DB440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 16:32:02 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id j1so12450721uah.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 13:32:02 -0700 (PDT)
Received: from mail-ua0-x235.google.com (mail-ua0-x235.google.com. [2607:f8b0:400c:c08::235])
        by mx.google.com with ESMTPS id a6si1896543uac.220.2017.07.12.13.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 13:32:02 -0700 (PDT)
Received: by mail-ua0-x235.google.com with SMTP id g13so2922202uaj.0
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 13:32:02 -0700 (PDT)
MIME-Version: 1.0
From: Vasilis Dimitsas <vdimitsas@gmail.com>
Date: Wed, 12 Jul 2017 23:31:21 +0300
Message-ID: <CAE=wTWYU8F5KDrC9VSxrtckVZ2xmvxy8owxCkZUcY4KXEiz0Og@mail.gmail.com>
Subject: asynchronous readahead prefetcher operation
Content-Type: multipart/alternative; boundary="94eb2c1915045a1f7e055424b5be"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--94eb2c1915045a1f7e055424b5be
Content-Type: text/plain; charset="UTF-8"

Good evening,

I am currently working on a project which is related to the operation of
the linux readahead prefetcher. As a result, I am trying to understand its
operation. Having read thoroughly the relevant part in the kernel code, I
realize, from the comments, that part of the prefetching occurs
asynchronously. The problem is that I can not verify this from the code.

Even if you call page_cache_sync_readahead() or
page_cache_async_readahead(), then both will end up in ra_submit(), in
which, the operation is common for both cases.

So, please could you tell me at which point does the operation of
prefetching occurs asynchronously?

Thank you in advance,

Vasilis Dimitsas

--94eb2c1915045a1f7e055424b5be
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Good evening,<div><br></div><div>I am currently working on=
 a project which is related to the operation of the linux readahead prefetc=
her. As a result, I am trying to understand its operation. Having read thor=
oughly the relevant part in the kernel code, I realize, from the comments, =
that part of the prefetching occurs asynchronously. The problem is that I c=
an not verify this from the code.</div><div><br></div><div>Even if you call=
 page_cache_sync_readahead() or page_cache_async_readahead(), then both wil=
l end up in ra_submit(), in which, the operation is common for both cases.<=
/div><div><br></div><div>So, please could you tell me at which point does t=
he operation of prefetching occurs asynchronously?</div><div><br></div><div=
>Thank you in advance,</div><div><br></div><div>Vasilis Dimitsas =C2=A0</di=
v></div>

--94eb2c1915045a1f7e055424b5be--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
