Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 96D126B02A3
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 02:32:15 -0400 (EDT)
Received: by lbgc1 with SMTP id c1so9746844lbg.1
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 23:32:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ7qFSdiGw1krDbWg6HvwBymp2gwrYKb8UuA00wSP0rgZi-EMw@mail.gmail.com>
References: <CAJ7qFSdiGw1krDbWg6HvwBymp2gwrYKb8UuA00wSP0rgZi-EMw@mail.gmail.com>
Date: Sat, 23 Jun 2012 12:02:13 +0530
Message-ID: <CAJ7qFScaFM5UHkjUe_wayB6rQQv31i6fN_3+uDh9+j15n88gig@mail.gmail.com>
Subject: Re: Crash with VMALLOC api
From: "R, Sricharan" <r.sricharan@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-omap@vger.kernel.org

Hi,
  BTW i was facing the issue on OMAP4430 SDP platform with
  mainline.

Thanks,
 Sricharan

On Sat, Jun 23, 2012 at 11:28 AM, R, Sricharan <r.sricharan@ti.com> wrote:
> Hi,
> =A0I am observing a below crash with VMALLOC call on mainline kernel.
> =A0The issue happens when there is insufficent vmalloc space.
> =A0Isn't it expected that the API should return a NULL instead of crashin=
g when
> =A0there is not enough memory?. This can be reproduced with succesive vma=
lloc
> =A0calls for a size of about say 10MB, without a vfree, thus exhausting
> the memory.
>
> =A0Strangely when vmalloc is requested for a large chunk, then at that ti=
me API
> =A0does not crash instead returns a NULL correctly.
>
> =A0Please correct me if my understanding is not correct..
>
> -------------------------------------------------------------------------=
-------------
>
> [ =A0345.059841] Unable to handle kernel paging request at virtual
> address 90011000
> [ =A0345.067063] pgd =3D ebc34000
> [ =A0345.069793] [90011000] *pgd=3D00000000
> [ =A0345.073383] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
> [ =A0345.078685] Modules linked in: bcmdhd cfg80211 inv_mpu_ak8975
> inv_mpu_kxtf9 mpu3050
> [ =A0345.086380] CPU: 0 =A0 =A0Tainted: G =A0 =A0 =A0 =A0W =A0 =A0 (3.4.0=
-rc1-05660-g0d4b175 #1)
> [ =A0345.093351] PC is at vmap_page_range_noflush+0xf0/0x200
> [ =A0345.098569] LR is at vmap_page_range+0x14/0x50
> [ =A0345.103005] pc : [<c01091c8>] =A0 =A0lr : [<c01092ec>] =A0 =A0psr: 8=
0000013
> [ =A0345.103009] sp : ebc41e38 =A0ip : fe000fff =A0fp : 00002000
> [ =A0345.114472] r10: c0a78480 =A0r9 : 90011000 =A0r8 : c096e2ac
> [ =A0345.119685] r7 : 90011000 =A0r6 : 00000000 =A0r5 : fe000000 =A0r4 : =
00000000
> [ =A0345.126198] r3 : 50011452 =A0r2 : f385c400 =A0r1 : fe000fff =A0r0 : =
f385c400
> [ =A0345.132713] Flags: Nzcv =A0IRQs on =A0FIQs on =A0Mode SVC_32 =A0ISA =
ARM =A0Segment user
> [ =A0345.139835] Control: 10c5387d =A0Table: abc3404a =A0DAC: 00000015
>
> Thanks,
> =A0Sricharan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
