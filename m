Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C7B0E6B006C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 13:07:24 -0400 (EDT)
Received: by vcbfl17 with SMTP id fl17so9009668vcb.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 10:07:23 -0700 (PDT)
MIME-Version: 1.0
From: Israel Jacquez <mrkotfw@gmail.com>
Date: Tue, 2 Oct 2012 10:07:03 -0700
Message-ID: <CAJdDbRBOf=GYuM90+8TSPYNNdHpNfUbT_G0QiZi-+TnVbudkJg@mail.gmail.com>
Subject: Some confusion with how the SLOB allocator works
Content-Type: multipart/alternative; boundary=20cf307c9b3e469a2804cb168eac
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--20cf307c9b3e469a2804cb168eac
Content-Type: text/plain; charset=UTF-8

Hello everyone,

I'm studying the SLOB allocator and I'm having a bit of a hard time
understanding how slob_page_alloc() works. Particularly, what I don't
understand is the structure of a "cleared" linked slob_page. For example,
the first slob_page is dedicated for allocations (0, 256B]. Let's assume
that no allocations have been done. Then if a single slob_page is 4KiB (2 ^
12) and each "block" is 2B (2 ^ 2) then are there 2 ^ 10 blocks in that
slob_page?

What is also confusing is what the metadata in each free/allocated block
represents. If there is allocation request of 64B, that would go into the
list of slob_page(s) dedicated to allocations within (0,256B]. The next
pointer is pointing to the very first block of the slob_page. What value
(in units) does that block have?

--20cf307c9b3e469a2804cb168eac
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div>Hello everyone,</div><div><br></div><div>I&#39;m studying the SLOB all=
ocator and I&#39;m having a bit of a hard time understanding how slob_page_=
alloc() works. Particularly, what I don&#39;t understand is the structure o=
f a &quot;cleared&quot; linked slob_page.=C2=A0For example, the first slob_=
page is dedicated for allocations (0, 256B]. Let&#39;s assume that no alloc=
ations have=C2=A0been done. Then if a single slob_page is 4KiB (2 ^ 12) and=
 each &quot;block&quot; is 2B (2 ^ 2) then are there 2 ^ 10 blocks in=C2=A0=
that slob_page?</div>




<div><br></div><div>What is also confusing is what the metadata in each fre=
e/allocated block represents.=C2=A0If there is allocation request of 64B, t=
hat would go into the list of slob_page(s) dedicated to allocations=C2=A0wi=
thin (0,256B]. The next pointer is pointing to the very first block of the =
slob_page. What value (in units)=C2=A0does that block have?</div>




<div><br></div>

--20cf307c9b3e469a2804cb168eac--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
