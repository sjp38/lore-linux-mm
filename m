Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 246396B0037
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 09:55:26 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id w61so7079051wes.21
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:55:25 -0700 (PDT)
Received: from mail-we0-x233.google.com (mail-we0-x233.google.com [2a00:1450:400c:c03::233])
        by mx.google.com with ESMTPS id gq6si10660921wib.42.2014.09.25.06.55.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 06:55:24 -0700 (PDT)
Received: by mail-we0-f179.google.com with SMTP id u56so82324wes.10
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:55:24 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 25 Sep 2014 22:55:24 +0900
Message-ID: <CALLJCT0YKkg=PZN1i4eOEWdJoLE8oAyTAk0OmRHLOGRstqk4MQ@mail.gmail.com>
Subject: [linux-next] mm/debug.c compile failure with CONFIG_MEMCG not set
From: Masanari Iida <standby24x7@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, sasha.levin@oracle.com, linux-mm@kvack.org

As of linux-next 20140925, if I don't set CONFIG_MEMCG,
the compile failed with following error.

mm/debug.c: In function =E2=80=98dump_mm=E2=80=99:
mm/debug.c:169:1183: error: =E2=80=98const struct mm_struct=E2=80=99 has no=
 member named =E2=80=98owner=E2=80=99
  pr_emerg("mm %p mmap %p seqnum %d task_size %lu\n"

make[1]: *** [mm/debug.o] Error 1

If I set CONFIG_MEMCG, the compile succeed.

Reported-by: Masanari Iida <standby24x7@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
