Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2516B00A8
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 20:27:25 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id g18so5427980oah.19
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 17:27:24 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id s3si25694354obd.77.2014.06.02.17.27.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 17:27:24 -0700 (PDT)
Received: by mail-ob0-f177.google.com with SMTP id wp4so5107255obc.8
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 17:27:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140424110321.GN26756@n2100.arm.linux.org.uk>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
	<20140424102229.GA28014@linaro.org>
	<20140424103639.GC19564@arm.com>
	<20140424104232.GK26756@n2100.arm.linux.org.uk>
	<CAPvkgC3P8iZp5nECiGHdeGzRwmdh=ouiAREqKwk1tYzZxHTWvg@mail.gmail.com>
	<20140424110321.GN26756@n2100.arm.linux.org.uk>
Date: Tue, 3 Jun 2014 03:27:24 +0300
Message-ID: <CANOLnOODjN1+OjK+M3V3anWZUhaThs6YE_mOHK4uET8xGPJT8Q@mail.gmail.com>
Subject: Re: [PATCH V2 0/5] Huge pages for short descriptors on ARM
From: Grazvydas Ignotas <notasas@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Steve Capper <steve.capper@linaro.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Siarhei Siamashka <siarhei.siamashka@gmail.com>

On Thu, Apr 24, 2014 at 2:03 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Thu, Apr 24, 2014 at 11:55:56AM +0100, Steve Capper wrote:
>> On 24 April 2014 11:42, Russell King - ARM Linux <linux@arm.linux.org.uk=
> wrote:
>> > On Thu, Apr 24, 2014 at 11:36:39AM +0100, Will Deacon wrote:
>> >> I guess I'm after some commitment that this is (a) useful to somebody=
 and
>> >> (b) going to be tested regularly, otherwise it will go the way of thi=
ngs
>> >> like big-endian, where we end up carrying around code which is broken=
 more
>> >> often than not (although big-endian is more self-contained).
>> >
>> > It may be something worth considering adding to my nightly builder/boo=
t
>> > testing, but I suspect that's impractical as it probably requires a BE
>> > userspace, which would then mean that the platform can't boot LE.
>> >
>> > I suspect that we will just have to rely on BE users staying around an=
d
>> > reporting problems when they occur.
>>
>> The huge page support is for standard LE, I think Will was saying that
>> this will be like BE if no-one uses it.
>
> We're not saying that.
>
> What we're asking is this: *Who* is using hugepages today?

We are using it on opanpandora handheld, it's really useful for doing
graphics in software. Here are some benchmarks I did some time ago:
http://lists.infradead.org/pipermail/linux-arm-kernel/2013-February/148835.=
html
For example Cortex-A8 only has 32 dTLB entries so they run out pretty
fast while drawing vertical lines on linear images. And it's not so
rare thing to do, like for drawing vertical scrollbars.

Other people find use for it too, like to get more consistent results
between benchmark runs:
http://ssvb.github.io/2013/06/27/fullhd-x11-desktop-performance-of-the-allw=
inner-a10.html

Yes in my case this is niche device and I can keep patching in the
hugepage support, but mainline support would make life easier and
would be very much appreciated.


--=20
Gra=C5=BEvydas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
