Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1671B6B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:53:18 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j12so55847030ywb.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:53:18 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id s22si6346563qts.105.2016.07.19.15.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 15:53:17 -0700 (PDT)
Received: by mail-qk0-x236.google.com with SMTP id p74so30157902qka.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:53:17 -0700 (PDT)
MIME-Version: 1.0
From: Zhan Chen <zhanc1@andrew.cmu.edu>
Date: Tue, 19 Jul 2016 15:53:16 -0700
Message-ID: <CAAs6xrzboZpT9o+u+xwnjVJHn_bip2jkZAg7gbQRVmv6VhAxxA@mail.gmail.com>
Subject: migration failure in 3.10 kernel
Content-Type: multipart/alternative; boundary=001a114fda9c59347f053804f3bc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-mm@kvack.org

--001a114fda9c59347f053804f3bc
Content-Type: text/plain; charset=UTF-8

Hi Naoya,

I encounter the issue that page migration fails due to page ref count != 1
thus return -EAGAIN in migrate_page_move_mapping().
And it turns out that in page fault handling, __migration_entry_wait()
calls get_page_unless_zero() to get an extra ref count before
wait_on_page_locked().

Is there a fix that can safely wait for migration to complete without
taking the ref on page?
Thanks.

-Zhan

--001a114fda9c59347f053804f3bc
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Naoya,<div><br><div>I encounter the issue that page mig=
ration fails due to page ref count !=3D 1 thus return -EAGAIN in=C2=A0migra=
te_page_move_mapping().</div><div>And it turns out that in page fault handl=
ing,=C2=A0__migration_entry_wait() calls=C2=A0get_page_unless_zero() to get=
 an extra ref count before wait_on_page_locked().</div><div><br></div><div>=
Is there a fix that can safely wait for migration to complete without takin=
g the ref on page?</div><div>Thanks.</div><div><br></div><div>-Zhan</div></=
div></div>

--001a114fda9c59347f053804f3bc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
