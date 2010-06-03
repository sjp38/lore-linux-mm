Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 778C06B01EB
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:51:43 -0400 (EDT)
Received: by bwz1 with SMTP id 1so172146bwz.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:51:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006011445100.9438@router.home>
References: <AANLkTimEFy6VM3InWlqhVooQjKGSD3yBxlgeRbQC2r1L@mail.gmail.com>
	<20100531165528.35a323fb.rdunlap@xenotime.net>
	<4C047CF9.9000804@tmr.com>
	<AANLkTilLq-hn59CBcLnOsnT37ZizQR6MrZX6btKPhfpb@mail.gmail.com>
	<20100601123959.747228c6.rdunlap@xenotime.net>
	<alpine.DEB.2.00.1006011445100.9438@router.home>
Date: Thu, 3 Jun 2010 09:51:41 +0300
Message-ID: <AANLkTinxOJShwd7xUornVI89BmJnbX9-a7LVWaciNdr5@mail.gmail.com>
Subject: Re: Possible bug in 2.6.34 slub
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Giangiacomo Mariotti <gg.mariotti@gmail.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 1, 2010 at 10:48 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Tue, 1 Jun 2010, Randy Dunlap wrote:
>
>> > >>> My cpu is an I7 920, so it has 4 cores and there's hyperthreading
>> > >>> enabled, so there are 8 logical cpus. Is this a bug?
>
> Yes its a bug in the arch code or BIOS. The system configuration tells us
> that there are more possible cpus and therefore the system prepares for
> the additional cpus to be activated at some later time.

I guess we should CC x86 maintainers then!

>> Sorry, I think that I misread your report.
>> It does look like misinformation.
>> Let's cc Christoph Lameter & Pekka.
>>
>>
>> > The point is, I guess(didn't actually look at the code), if that's
>> > just the count of MAX number of cpus supported, which is a config time
>> > =A0define and then the actual count gets refined afterwards by slub
>> > too(because I know that the rest of the kernel knows I've got 4
>> > cores/8 logical cpus) or not. Is that it? If this is not the case(that
>> > is, it's not a static define used as a MAX value), then I can't see
>> > what kind of boot/init time info it is. If it's a boot-time info, it
>> > just means it's a _wrong_ boot-time info.
>
> No that is the max nr of cpus possible on this machine. The count is
> determined by hardware capabilities on bootup. If they are not detected
> in the right way then you have the erroneous display (and the system
> configures useless per cpu structures to support nonexistent cpus).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
