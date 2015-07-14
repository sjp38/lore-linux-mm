Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 573C09003C8
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 04:41:05 -0400 (EDT)
Received: by qgep37 with SMTP id p37so1163213qge.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 01:41:05 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id 74si278459qhq.106.2015.07.14.01.41.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Jul 2015 01:41:04 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH v2 0/3] memtest cleanups
Date: Tue, 14 Jul 2015 09:40:46 +0100
Message-Id: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, leon@leon.nu

Hi,

This patch set does simple cleanup in mm/memtest.c code.

There is no changes in functionality, but some logging may slightly differ
after patch 2/3 is applied.

Patches were generated against 4.2-rc2

Thanks!

Changelog:

v1 -> v2
=09- do not fallback to the memtest_pattern =3D ARRAY_SIZE(patterns) in
          case we couldn't parse memtest's arg (per Leon Romanovsky)


Vladimir Murzin (3):
  memtest: use kstrtouint instead of simple_strtoul
  memtest: cleanup log messages
  memtest: remove unused header files

 mm/memtest.c |   27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

--=20
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
