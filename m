Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B73F26B00A1
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:44:46 -0400 (EDT)
Received: by iwn1 with SMTP id 1so4084055iwn.14
        for <linux-mm@kvack.org>; Wed, 20 Oct 2010 06:44:44 -0700 (PDT)
MIME-Version: 1.0
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Wed, 20 Oct 2010 19:14:13 +0530
Message-ID: <AANLkTikn_44WcCBmWUW=8E3q3=cznZNx=dHdOcgZSKgH@mail.gmail.com>
Subject: TMPFS Maximum File Size
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: hughd@google.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh/All,

Is there any kind of file size limitation in TMPFS ?
Our application SEGFAULT inside write() after filling 70% of TMPFS
mount. (re-creatable but does not happen every time).

We are using 98GB TMPFS without swap device. i.e. SWAP is turned off.
Applications does not take approx. 20GB memory.

we have Physical RAM of 128GB Intel x86 box running SLES 11 64bit.
We use Infiniband, export TMPFS over NFS and IBM GPFS in same box.
(hope those won't affect)

Bit confused about "triple-indirect swap vector" ?

Extracted from shmem.c ....

/*
=C2=A0* The maximum size of a shmem/tmpfs file is limited by the maximum si=
ze of
=C2=A0* its triple-indirect swap vector - see illustration at shmem_swp_ent=
ry().
=C2=A0*
=C2=A0* With 4kB page size, maximum file size is just over 2TB on a 32-bit =
kernel,
=C2=A0* but one eighth of that on a 64-bit kernel.=C2=A0 With 8kB page size=
, maximum
=C2=A0* file size is just over 4TB on a 64-bit kernel, but 16TB on a 32-bit=
 kernel,
=C2=A0* MAX_LFS_FILESIZE being then more restrictive than swap vector layou=
t.
 *

Thankx a lot.
__
Tharindu R Bamunuarachchi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
