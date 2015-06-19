Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7866B008A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:58:53 -0400 (EDT)
Received: by qkfe185 with SMTP id e185so62143424qkf.3
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 07:58:53 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTP id 21si11127249qkw.0.2015.06.19.07.58.51
        for <linux-mm@kvack.org>;
        Fri, 19 Jun 2015 07:58:52 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 0/3] memtest cleanups
Date: Fri, 19 Jun 2015 15:58:31 +0100
Message-Id: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Hi,

This patch set does simple cleanup in mm/memtest.c code.

There is no changes in functionality, but some logging may slightly differ
after patch 2/3 is applied.

It was generated against 4.1-rc8

Thanks!

Vladimir Murzin (3):
  memtest: use kstrtouint instead of simple_strtoul
  memtest: cleanup log messages
  memtest: remove unused header files

 mm/memtest.c |   33 ++++++++++++++-------------------
 1 file changed, 14 insertions(+), 19 deletions(-)

--=20
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
