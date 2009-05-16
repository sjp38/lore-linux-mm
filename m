Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 08BD06B0055
	for <linux-mm@kvack.org>; Sat, 16 May 2009 10:52:16 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1221354ywm.26
        for <linux-mm@kvack.org>; Sat, 16 May 2009 07:53:05 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 16 May 2009 22:53:05 +0800
Message-ID: <ab418ea90905160753v52d82b2bj3fe3c85ea167a811@mail.gmail.com>
Subject: multiple address_space mappings
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, all

It may be a stupid question. But if a page (composed of contiguous
blocks)on a disk was read through two different paths --- one from
mmap of a regular file and another is direct reading of the block
device. Can they share the same page frame ?  If they can, should this
page have two page->mappings ?
It they cannot (I think this maybe true), how should we consider this
inconsistency?

Thanks !

Regards,

Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
