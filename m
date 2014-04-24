Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 04B4E6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 06:55:57 -0400 (EDT)
Received: by mail-yk0-f173.google.com with SMTP id 10so1907088ykt.18
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:55:57 -0700 (PDT)
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
        by mx.google.com with ESMTPS id w9si4508013yhk.19.2014.04.24.03.55.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 03:55:56 -0700 (PDT)
Received: by mail-yh0-f52.google.com with SMTP id 29so2017376yhl.25
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:55:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140424104232.GK26756@n2100.arm.linux.org.uk>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
	<20140424102229.GA28014@linaro.org>
	<20140424103639.GC19564@arm.com>
	<20140424104232.GK26756@n2100.arm.linux.org.uk>
Date: Thu, 24 Apr 2014 11:55:56 +0100
Message-ID: <CAPvkgC3P8iZp5nECiGHdeGzRwmdh=ouiAREqKwk1tYzZxHTWvg@mail.gmail.com>
Subject: Re: [PATCH V2 0/5] Huge pages for short descriptors on ARM
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Will Deacon <will.deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "robherring2@gmail.com" <robherring2@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On 24 April 2014 11:42, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> On Thu, Apr 24, 2014 at 11:36:39AM +0100, Will Deacon wrote:
>> I guess I'm after some commitment that this is (a) useful to somebody and
>> (b) going to be tested regularly, otherwise it will go the way of things
>> like big-endian, where we end up carrying around code which is broken more
>> often than not (although big-endian is more self-contained).
>
> It may be something worth considering adding to my nightly builder/boot
> testing, but I suspect that's impractical as it probably requires a BE
> userspace, which would then mean that the platform can't boot LE.
>
> I suspect that we will just have to rely on BE users staying around and
> reporting problems when they occur.

The huge page support is for standard LE, I think Will was saying that
this will be like BE if no-one uses it.
I would appreciate any extra testing a *lot*. :-).

It's somewhat unfair to compare huge pages on short descriptors with
BE. For a start, the userspace that works with LPAE will work on the
short-descriptor kernel too. Great care has been taken to ensure that
programmers can just port their huge page code over to ARM from other
architectures without any issues. As things like libhugetlbfs (which
fully supports ARM) get incorporated into distros on ARM, huge pages
become the norm as opposed to the exception.

Some devices have very few TLBs and I believe this series will be very
beneficial for people using those devices.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
