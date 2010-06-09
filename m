Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7194C6B01D2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 22:44:13 -0400 (EDT)
Received: by vws19 with SMTP id 19so952151vws.14
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 19:44:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTilsCkBiGtfEKkNXYclsRKhfuq4yI_1mrxMa8yJG@mail.gmail.com>
References: <AANLkTin1OS3LohKBvWyS81BoAk15Y-riCiEdcevSA7ye@mail.gmail.com>
	<1275929000.3021.56.camel@e102109-lin.cambridge.arm.com>
	<AANLkTilsCkBiGtfEKkNXYclsRKhfuq4yI_1mrxMa8yJG@mail.gmail.com>
Date: Wed, 9 Jun 2010 10:44:10 +0800
Message-ID: <AANLkTilbhdPy8tq-brAotFDlOkyZxB3uEXSD-PQJLpBL@mail.gmail.com>
Subject: Re: mmotm 2010-06-03-16-36 lots of suspected kmemleak
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 9, 2010 at 10:37 AM, Dave Young <hidave.darkstar@gmail.com> wro=
te:
> On Tue, Jun 8, 2010 at 12:43 AM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
>> On Mon, 2010-06-07 at 11:00 +0100, Dave Young wrote:
>>> On Mon, Jun 7, 2010 at 5:19 PM, Catalin Marinas <catalin.marinas@arm.co=
m> wrote:
>>> > On Mon, 2010-06-07 at 06:20 +0100, Dave Young wrote:
>>> >> On Fri, Jun 4, 2010 at 9:55 PM, Dave Young <hidave.darkstar@gmail.co=
m> wrote:
>>> >> > On Fri, Jun 4, 2010 at 6:50 PM, Catalin Marinas <catalin.marinas@a=
rm.com> wrote:
>>> >> >> Dave Young <hidave.darkstar@gmail.com> wrote:
>>> >> >>> With mmotm 2010-06-03-16-36, I gots tuns of kmemleaks
>>> >> >>
>>> >> >> Do you have CONFIG_NO_BOOTMEM enabled? I posted a patch for this =
but
>>> >> >> hasn't been reviewed yet (I'll probably need to repost, so if it =
fixes
>>> >> >> the problem for you a Tested-by would be nice):
>>> >> >>
>>> >> >> http://lkml.org/lkml/2010/5/4/175
>>> >> >
>>> >> >
>>> >> > I'd like to test, but I can not access the test pc during weekend.=
 So
>>> >> > I will test it next monday.
>>> >>
>>> >> Bad news, the patch does not fix this issue.
>>> >
>>> > Thanks for trying. Could you please just disable CONFIG_NO_BOOTMEM an=
d
>>> > post the kmemleak reported leaks again?
>>>
>>> Still too many suspected leaks, results similar with
>>> (CONFIG_NO_BOOTMEM =3D y && apply your patch), looks like a little
>>> different from original ones? I just copy some of them here:
>>>
>>> unreferenced object 0xde3c7420 (size 44):
>>> =C2=A0 comm "bash", pid 1631, jiffies 4294897023 (age 223.573s)
>>> =C2=A0 hex dump (first 32 bytes):
>>> =C2=A0 =C2=A0 05 05 00 00 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0...=
..N..........
>>> =C2=A0 =C2=A0 98 42 d9 c1 00 00 00 00 50 fe 63 c1 10 32 8f dd =C2=A0.B.=
.....P.c..2..
>>> =C2=A0 backtrace:
>>> =C2=A0 =C2=A0 [<c1498ad2>] kmemleak_alloc+0x4a/0x83
>>> =C2=A0 =C2=A0 [<c10c1ace>] kmem_cache_alloc+0xde/0x12a
>>> =C2=A0 =C2=A0 [<c10b421b>] anon_vma_fork+0x31/0x88
>>> =C2=A0 =C2=A0 [<c102c71d>] dup_mm+0x1d3/0x38f
>>> =C2=A0 =C2=A0 [<c102d20d>] copy_process+0x8ce/0xf39
>>> =C2=A0 =C2=A0 [<c102d990>] do_fork+0x118/0x295
>>> =C2=A0 =C2=A0 [<c1007fe0>] sys_clone+0x1f/0x24
>>> =C2=A0 =C2=A0 [<c10029b1>] ptregs_clone+0x15/0x24
>>> =C2=A0 =C2=A0 [<ffffffff>] 0xffffffff
>>
>> I'll try to test the mmotm kernel as well. I don't get any kmemleak
>> reports with the 2.6.35-rc1 kernel.

maybe you do not set CONFIG_KSM?

>
> Manually bisected mm patches, the memleak caused by following patch:
>
> mm-extend-ksm-refcounts-to-the-anon_vma-root.patch
>
> cc Rik van Riel
>
>>
>> Can you send me your .config file? Do you have CONFIG_HUGETLBFS enabled?
>>
>> Thanks.
>>
>> --
>> Catalin
>>
>>
>
>
>
> --
> Regards
> dave
>



--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
