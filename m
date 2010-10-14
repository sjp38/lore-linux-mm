Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6701B6B0167
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 08:09:17 -0400 (EDT)
Received: by bwz19 with SMTP id 19so463691bwz.14
        for <linux-mm@kvack.org>; Thu, 14 Oct 2010 05:09:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101014160217N.fujita.tomonori@lab.ntt.co.jp>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<87sk0a1sq0.fsf@basil.nowhere.org>
	<20101014160217N.fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 14 Oct 2010 15:09:13 +0300
Message-ID: <AANLkTin-8mjL_B8g9cPoviQU0FUaEyb_v5_Fm4kbSweA@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: andi@firstfloor.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 10:07 AM, FUJITA Tomonori
<fujita.tomonori@lab.ntt.co.jp> wrote:
> On Wed, 13 Oct 2010 09:01:43 +0200
> Andi Kleen <andi@firstfloor.org> wrote:
>
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
>> >
>> > What this wants to do:
>> > =C2=A0 allocates a contiguous chunk of pages larger than MAX_ORDER.
>> > =C2=A0 for device drivers (camera? etc..)
>>
>> I think to really move forward you need a concrete use case
>> actually implemented in tree.
>
> As already pointed out, some embeded drivers need physcailly
> contignous memory. Currenlty, they use hacky tricks (e.g. playing with
> the boot memory allocators). There are several proposals for this like
> adding a new kernel memory allocator (from samsung).
>
> It's ideal if the memory allocator can handle this, I think.

Not only contiguous, but sometimes also coherent.

--=20
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
