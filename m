Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB51F6B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 01:46:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id x130so17165257ite.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 22:46:29 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id v193si10344099itc.69.2016.08.10.22.46.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 22:46:29 -0700 (PDT)
Received: from epcas2p2.samsung.com (unknown [182.195.41.54])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OBQ01AZJDDFJX00@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 11 Aug 2016 14:46:27 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
In-reply-to: 
 <CAOaiJ-=ZBFnFOJE1ZZySY2JPO9MVTeKA25PzGsqJ=z+darwY8w@mail.gmail.com>
Subject: RE: [linux-mm] Drastic increase in application memory usage with
 Kernel version upgrade
Date: Thu, 11 Aug 2016 11:15:41 +0530
Message-id: <000801d1f393$a89627d0$f9c27770$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: quoted-printable
Content-language: en-us
References: 
 <CGME20160805045709epcas3p1dc6f12f2fa3031112c4da5379e33b5e9@epcas3p1.samsung.com>
 <01a001d1eed5$c50726c0$4f157440$@samsung.com> <20160805082015.GA28235@bbox>
 <01c101d1ef28$50706ad0$f1514070$@samsung.com> <20160805205018.GE7999@amd>
 <006e01d1f30a$bfc7f430$3f57dc90$@samsung.com>
 <CAOaiJ-=ZBFnFOJE1ZZySY2JPO9MVTeKA25PzGsqJ=z+darwY8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'vinayak menon' <vinayakm.list@gmail.com>
Cc: 'Pavel Machek' <pavel@ucw.cz>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, 'Minchan Kim' <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaejoon.seo@samsung.com, jy0.jeon@samsung.com, vishnu.ps@samsung.com, chulspro.kim@samsung.com

Hi,
> -----Original Message-----
> From: vinayak menon [mailto:vinayakm.list@gmail.com]
> Sent: Thursday, August 11, 2016 10:23 AM
> To: PINTU KUMAR
> Cc: Pavel Machek; Konstantin Khlebnikov; Minchan Kim; linux-
> kernel@vger.kernel.org; linux-mm@kvack.org; jaejoon.seo@samsung.com;
> jy0.jeon@samsung.com; vishnu.ps@samsung.com; chulspro.kim@samsung.com
> Subject: Re: [linux-mm] Drastic increase in application memory usage =
with Kernel
> version upgrade
>=20
> On Wed, Aug 10, 2016 at 6:56 PM, PINTU KUMAR <pintu.k@samsung.com> =
wrote:
> > Hi,
> >
> >> -----Original Message-----
> >> From: Pavel Machek [mailto:pavel@ucw.cz]
> >> Sent: Saturday, August 06, 2016 2:20 AM
> >> To: PINTU KUMAR
> >> Cc: 'Minchan Kim'; linux-kernel@vger.kernel.org; =
linux-mm@kvack.org;
> >> jaejoon.seo@samsung.com; jy0.jeon@samsung.com;
> vishnu.ps@samsung.com
> >> Subject: Re: [linux-mm] Drastic increase in application memory =
usage
> >> with
> > Kernel
> >> version upgrade
> >>
> >> On Fri 2016-08-05 20:17:36, PINTU KUMAR wrote:
> >> > Hi,
> >>
> >> > > On Fri, Aug 05, 2016 at 10:26:37AM +0530, PINTU KUMAR wrote:
> >> > > > Hi All,
> >> > > >
> >> > > > For one of our ARM embedded product, we recently updated the
> >> > > > Kernel version from 3.4 to 3.18 and we noticed that the same
> >> > > > application memory usage  (PSS value) gone up by ~10% and for
> >> > > > some cases it even crossed ~50%. There is no change in =
platform
> >> > > > part. All platform component was  built with ARM 32-bit =
toolchain.
> >> > > > However, the Kernel is changed from 32-bit to 64-bit.
> >> > > >
> >> > > > Is upgrading Kernel version and moving from 32-bit to 64-bit =
is
> >> > > > such a risk?
> >> > > > After the upgrade, what can we do further to reduce the
> >> > > > application memory usage ?
> >> > > > Is there any other factor that will help us to improve =
without
> >> > > > major modifications in platform ?
> >> > > >
> >> > > > As a proof, we did a small experiment on our Ubuntu-32 bit =
machine.
> >> > > > We upgraded Ubuntu Kernel version from 3.13 to 4.01 and we
> >> > > > observed the following:
> >> > > > =
---------------------------------------------------------------
> >> > > > ---
> >> > > > |UBUNTU-32 bit  |Kernel 3.13    |Kernel 4.03    |DIFF   |
> >> > > > |CALCULATOR PSS |6057 KB        |6466 KB        |409 KB |
> >> > > > =
---------------------------------------------------------------
> >> > > > --- So, just by upgrading the Kernel version: PSS value for
> >> > > > calculator is increased by 409KB.
> >> > > >
> >> > > > If anybody knows any in-sight about it please point out more
> >> > > > details about the root cause.
> >> > >
> >> > > One of culprit is [8c6e50b0290c, mm: introduce =
vm_ops->map_pages()].
> >> > Ok. Thank you for your reply.
> >> > So, if I revert this patch, will the memory usage be decreased =
for
> >> > the processes with Kernel 3.18 ?
> >>
> >> I guess you should try it...
> >>
> > Thanks for the reply and confirmation.
> > Our exact kernel version is: 3.18.14
> > And, we already have this patch:
> > /*
> > mm: do not call do_fault_around for non-linear fault Ingo Korb
> > reported that "repeated mapping of the same file on tmpfs using
> > remap_file_pages sometimes triggers a BUG at mm/filemap.c:202 when =
the
> > process exits".
> > He bisected the bug to d7c1755179b8 ("mm: implement ->map_pages for
> > shmem/tmpfs"), although the bug was actually added by commit
> > 8c6e50b0290c ("mm: introduce vm_ops->map_pages()").
> > */
> >
> > So, I guess, reverting this patch (8c6e50b0290c), is not required ?
> > But, still we have memory usage issue.
> >
> I had observed the PSS increase with 3.18, and that was because of the
> faultaround patch which MInchan mentioned.
> Without reverting the patch you can just try reducing =
fault_around_bytes
> (mm/memory.c) to PAGE_SIZE. That should bring down the PSS.
>=20
Thanks for your reply.
I tried changing fault_around_bytes value from 65536 to 4096.
But, still there is no change in PSS.
Please let me know if anything is missing.
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2776,7 +2776,8 @@ void do_set_pte(struct vm_area_struct *vma, =
unsigned long address,
 }
 static unsigned long fault_around_bytes __read_mostly =3D
-       rounddown_pow_of_two(65536);
+       rounddown_pow_of_two(PAGE_SIZE);

> Thanks,
> Vinayak


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
