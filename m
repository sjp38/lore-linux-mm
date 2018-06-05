Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A78E6B0006
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 15:14:15 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id v4-v6so2845779iol.8
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 12:14:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h10-v6sor18593065iog.101.2018.06.05.12.14.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 12:14:14 -0700 (PDT)
MIME-Version: 1.0
From: Rafael Telles <rafaelt@simbioseventures.com>
Date: Tue, 5 Jun 2018 16:14:02 -0300
Message-ID: <CAJ6kbHezPzbLW=1mwdnywMn639X4eLz9nnRZdk6oeyLjXR6mQg@mail.gmail.com>
Subject: Memory mapped pages not being swapped out
Content-Type: multipart/alternative; boundary="0000000000000e8088056de9dbab"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--0000000000000e8088056de9dbab
Content-Type: text/plain; charset="UTF-8"

Hi there, I am running a program where I need to map hundreds of thousands
of files and each file has several kilobytes (min. of 4kb per file). The
program calls mmap() for every 4096 bytes on each file, ending up with
millions of memory mapped pages, so I have ceil(N/4096) pages for each
file, where N is the file size.

As the program runs, more files are created and the older files get bigger,
then I need to remap those pages, so it's always adding more pages.

I am concerned about when and how Linux is going to swap out pages in order
to get more memory, the program seems to only increase memory usage overall
and I am afraid it runs out of memory.

I tried setting these sysctl parameters so it would swap out as soon as
possible (just to understand how Linux memory management works), but it
didn't change anything:

vm.zone_reclaim_mode = 1
vm.min_unmapped_ratio = 99


How can I be sure the program won't run out of memory? Do I have to
manually unmap pages to free memory?

Thanks so much

--0000000000000e8088056de9dbab
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span style=3D"color:rgb(33,33,33);font-size:13px">Hi ther=
e, I am running a program where I need to map hundreds of thousands of file=
s and each file has several kilobytes (min. of 4kb per file). The program c=
alls mmap() for every 4096 bytes on each file, ending up with millions of m=
emory mapped pages, so I have ceil(N/4096) pages for each file, where N is =
the file size.</span><div style=3D"color:rgb(33,33,33);font-size:13px"><br>=
</div><div style=3D"color:rgb(33,33,33);font-size:13px">As the program runs=
, more files are created and the older files get bigger, then I need to rem=
ap those pages, so it&#39;s always adding more pages.</div><div style=3D"co=
lor:rgb(33,33,33);font-size:13px"><br></div><div style=3D"color:rgb(33,33,3=
3);font-size:13px">I am concerned about when and how Linux is going to swap=
 out pages in order to get more memory, the program seems to only increase =
memory usage overall and I am afraid it runs out of memory.</div><div style=
=3D"color:rgb(33,33,33);font-size:13px"><br></div><div style=3D"color:rgb(3=
3,33,33);font-size:13px">I tried setting these sysctl parameters so it woul=
d swap out as soon as possible (just to understand how Linux memory managem=
ent works), but it didn&#39;t change anything:</div><div style=3D"color:rgb=
(33,33,33);font-size:13px"><br></div><div style=3D"color:rgb(33,33,33);font=
-size:13px"><div>vm.zone_reclaim_mode =3D 1</div><div>vm.min_unmapped_ratio=
 =3D 99</div></div><div style=3D"color:rgb(33,33,33);font-size:13px"><br></=
div><div style=3D"color:rgb(33,33,33);font-size:13px"><br></div><div style=
=3D"color:rgb(33,33,33);font-size:13px">How can I be sure the program won&#=
39;t run out of memory? Do I have to manually unmap pages to free memory?</=
div><div style=3D"color:rgb(33,33,33);font-size:13px"><br></div><div style=
=3D"color:rgb(33,33,33);font-size:13px">Thanks so much</div></div>

--0000000000000e8088056de9dbab--
