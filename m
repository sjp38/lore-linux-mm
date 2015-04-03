Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7971B6B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 07:03:49 -0400 (EDT)
Received: by wizk4 with SMTP id k4so41402307wiz.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 04:03:49 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id ff4si2793000wib.106.2015.04.03.04.03.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 04:03:48 -0700 (PDT)
Received: by widdi4 with SMTP id di4so104909929wid.0
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 04:03:48 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 3 Apr 2015 16:33:47 +0530
Message-ID: <CADbBBSoFoZQ4i++=wm1DZQrnULuvn22=Obj2b=99YyQ+o2HB1w@mail.gmail.com>
Subject: The zoned page frame allocator and fix mapped virtual addresses
From: Sunny Shah <shahsunny715@gmail.com>
Content-Type: multipart/alternative; boundary=f46d04428d1c1356090512cfe733
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--f46d04428d1c1356090512cfe733
Content-Type: text/plain; charset=UTF-8

Hello,

I had several questions about the zoned page frame allocator and fix mapped
virtual addresses from my reading of the book "Understanding the Linux
Kernel". I posted this on the kernelnewbies list, but haven't received any
response yet. Hoping for someone on this list to help me out.

   - It is possible for a page to be in ZONE_NORMAL and yet have it's
   PG_reserved flag cleared. Is this correct ?
   - The function "fix_to_virt" for fix-mapped linear addresses does the
   following:

   return (0xfffff000UL - (idx << PAGE_SHIFT));

   Why are the upper 4096 bytes not used, and the addressing starts from
   the top of the virtual address space - 4096 ?
   - The book says "each fix-mapped linear address maps one page frame of
   the physical memory". Shouldn't it be "maps one *physical location* of
   memory" rather than one page frame ?
   - My understanding is that the kernel page table entries for addresses >
   896 MB would be empty and those addresses would be mapped using separate
   data structures used for temporary and permanent kernel mappings and
   non-contiguous page frame allocation. Is this wrong ?

Thanks,
Sunny

--f46d04428d1c1356090512cfe733
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hello,</div><div><br></div><div>I had several questio=
ns about the zoned page frame allocator and fix mapped virtual addresses fr=
om my reading of the book &quot;Understanding the Linux Kernel&quot;. I pos=
ted this on the kernelnewbies list, but haven&#39;t received any response y=
et. Hoping for someone on this list to help me out.</div><ul><li>It is poss=
ible for a page to be in ZONE_NORMAL and yet have it&#39;s PG_reserved flag=
 cleared. Is this correct ?</li><li>The function &quot;fix_to_virt&quot; fo=
r fix-mapped linear addresses does the following:<br><br>return (0xfffff000=
UL - (idx &lt;&lt; PAGE_SHIFT));<br><br>Why are the upper 4096 bytes not us=
ed, and the addressing starts from the top of the virtual address space - 4=
096 ?</li><li>The book says &quot;each fix-mapped linear address maps one p=
age frame of the physical memory&quot;. Shouldn&#39;t it be &quot;maps one=
=C2=A0<i>physical location</i>=C2=A0of memory&quot; rather than one page fr=
ame ?</li><li>My understanding is that the kernel page table entries for ad=
dresses &gt; 896 MB would be empty and those addresses would be mapped usin=
g separate data structures used for temporary and permanent kernel mappings=
 and non-contiguous page frame allocation. Is this wrong ?</li></ul><div>Th=
anks,</div><div>Sunny</div></div>

--f46d04428d1c1356090512cfe733--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
