Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8A12E8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:41:40 -0500 (EST)
Received: by iwn40 with SMTP id 40so778718iwn.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 08:41:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110120161436.GB21494@random.random>
References: <20110120154935.GA1760@barrios-desktop>
	<20110120161436.GB21494@random.random>
Date: Fri, 21 Jan 2011 01:41:02 +0900
Message-ID: <AANLkTikHNcD3aOWKJdPtCqdJi9C34iLPxj5-L8=gqBFc@mail.gmail.com>
Subject: Re: [BUG]thp: BUG at mm/huge_memory.c:1350
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 1:14 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> Hello Minchan,
>
> On Fri, Jan 21, 2011 at 12:49:35AM +0900, Minchan Kim wrote:
>> Hi Andrea,
>>
>> I hit thg BUG 2 time during 5 booting.
>> I applied khugepaged: fix pte_unmap for highpte x86_32 based on 2.6.38-r=
c1.
>
> This is again 32bit which rings a bell because clearly it didn't have
> a whole lot of testing (not remotely comparable to the amount of
> testing x86-64 had), but it's not necessarily 32bit related. It still
> would be worth to know if it still happens after you disable
> CONFIG_HIGHMEM (to rule out 32bit issues in not well tested kmaps).
>

I wii try it at tomorrow.

> The rmap walk simply didn't find an hugepmd pointing to the page. Or
> the mapcount was left pinned after the page got somehow unmapped.
>
> I wonder why pages are added to swap and the system is so low on
> memory during boot. How much memory do you have in the 32bit system?

That was my curiosity, too.

> Do you boot with something like mem=3D256m? =A0This is also the Xorg

No. I didn't limit mem size. My system has a 2G memory.

> process, which is a bit more special than most and it may have device
> drivers attached to the pages.

Both bugs are hit by Xorg.
I doubt it.

>
> One critical thing is that split_huge_page must be called when
> splitting vmas, see split_huge_page_address and
> __vma_adjust_trans_huge, right now it's called from vma_adjust
> only. If anything is wrong in that function, or if any place adjusting
> the vma is not covered by that function, it may result in exactly the
> problem you run into. If drivers are mangling over the vmas that would
> also explain it.
>
> If you happen to have crash dump with vmlinux that would be the best
> debug option for this, also if you can reproduce it in a VM that will
> make it easier to reproduce without your hardware. Otherwise we'll
> find another way.

I will investigate it after out of office at tomorrow. Sorry but here
is 1:40 am. :)
If you have a any guess or good method to investigate the bug, please reply=
