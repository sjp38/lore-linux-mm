Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A49B6B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 20:30:36 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id f7so66127630vkb.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 17:30:36 -0700 (PDT)
Received: from mail-qk0-x234.google.com (mail-qk0-x234.google.com. [2607:f8b0:400d:c09::234])
        by mx.google.com with ESMTPS id e2si1455950qkd.256.2016.07.12.17.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 17:30:35 -0700 (PDT)
Received: by mail-qk0-x234.google.com with SMTP id o67so30008538qke.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 17:30:35 -0700 (PDT)
MIME-Version: 1.0
From: Zhan Chen <zhanc1@andrew.cmu.edu>
Date: Tue, 12 Jul 2016 17:30:34 -0700
Message-ID: <CAAs6xrw+UDeBJE1WKG9FK-YFN6xLDbA_c=_-y857fsRcO9K=Zw@mail.gmail.com>
Subject: 3.10 kernel issue: dequeue_hwpoisoned_huge_page fails in soft offline
Content-Type: multipart/alternative; boundary=001a114fda9c6ef6380537797e5d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andi@firstfloor.org
Cc: linux-mm@kvack.org

--001a114fda9c6ef6380537797e5d
Content-Type: text/plain; charset=UTF-8

Hi Andi,

I encounter an issue with 3.10 kernel where soft offlined huge page can not
be dequeued. Specifically, in function soft_offline_huge_page,
 dequeue_hwpoisoned_huge_page returns negative. It turns out that right
after the page is put_page, it's grabbed by some thread again.

Is there a fix that can prevent offlined pages being put back in use?
Plus, from the comment, dequeue_hwpoisoned_huge_page assumes caller holding
the page lock, which is not the case in this context, would this be a
problem in this case ?
Thank you.
-Zhan

--001a114fda9c6ef6380537797e5d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi Andi,</div><div><br></div><div>I encounter an issu=
e with 3.10 kernel where soft offlined huge page can not be dequeued. Speci=
fically, in function soft_offline_huge_page, =C2=A0dequeue_hwpoisoned_huge_=
page returns negative. It turns out that right after the page is put_page, =
it&#39;s grabbed by some thread again.</div><div><br></div><div>Is there a =
fix that can prevent offlined pages being put back in use?</div><div>Plus, =
from the comment, dequeue_hwpoisoned_huge_page assumes caller holding the p=
age lock, which is not the case in this context, would this be a problem in=
 this case ?</div><div>Thank you.</div><div>-Zhan=C2=A0</div></div>

--001a114fda9c6ef6380537797e5d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
