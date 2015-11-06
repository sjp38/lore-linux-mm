Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0B64282F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 18:05:29 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so111738814pac.3
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 15:05:28 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id i9si3118872pbq.207.2015.11.06.15.05.27
        for <linux-mm@kvack.org>;
        Fri, 06 Nov 2015 15:05:28 -0800 (PST)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 2FFC52074B
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 23:05:27 +0000 (UTC)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E3FAE20722
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 23:05:24 +0000 (UTC)
Received: by wmll128 with SMTP id l128so52690799wml.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 15:05:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7hmvuqg3f1.fsf@deeprootsystems.com>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
	<20151105094615.GP8644@n2100.arm.linux.org.uk>
	<563B81DA.2080409@redhat.com>
	<20151105162719.GQ8644@n2100.arm.linux.org.uk>
	<563BFCC4.8050705@redhat.com>
	<CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
	<563CF510.9080506@redhat.com>
	<CAGXu5jKLgL0Kt5xCWv-3ZUX94m1DNXLqsEDQKHoq7T=m6P7tvQ@mail.gmail.com>
	<CAGXu5j+Jeg-Cwc7Tr8UeY9vkJLudw07+b=m0h-d9GuSyKiO4QA@mail.gmail.com>
	<CAMAWPa9XvdS+dF78c7Fgs4ekRy7wVnfFT=0A5NLpu0UYaqV7fA@mail.gmail.com>
	<CAGXu5j+U-Q2R1Hw4qSPpFUKz3xyYrASGc5buMJTSy0K-3mWHBA@mail.gmail.com>
	<7h8u6ahm7d.fsf@deeprootsystems.com>
	<CAGXu5jJnjHkkX3y31y5LJFhNrP=A8_BASg2MUR5rwA5MLPeVQg@mail.gmail.com>
	<7hmvuqg3f1.fsf@deeprootsystems.com>
Date: Fri, 6 Nov 2015 15:05:23 -0800
Message-ID: <CAMAWPa_i9H9nw_hY5-=hJmenhXW2u_9DSKgZ5mEV0c_afGgqcQ@mail.gmail.com>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
From: Kevin Hilman <khilman@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, info@kernelci.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Tyler Baker <tyler.baker@linaro.org>

On Fri, Nov 6, 2015 at 2:37 PM, Kevin Hilman <khilman@kernel.org> wrote:
> Kees Cook <keescook@chromium.org> writes:
>
>> On Fri, Nov 6, 2015 at 1:06 PM, Kevin Hilman <khilman@kernel.org> wrote:
>
> [...]
>
>> Well, all the stuff I wrote tests for in lkdtm expect the kernel to
>> entirely Oops, and examining the Oops from outside is needed to verify
>> it was the correct type of Oops. I don't think testing via lkdtm can
>> be done from kselftest sensibly.
>
> Well, at least on arm32, it's definitely oops'ing, but it's not a full
> panic, so the oops could be grabbed from dmesg.
>
> FWIW, below is a log from and arm32 board running mainline v4.3 that
> runs through all the non-panic/lockup tests one after the other without
> a reboot.

... however, a run on arm64 and it locks up after the OVERFLOW test,
so I think you're right that we need an "outside observer" to reliably
determine pass/fail on these.  We'll start looking at that.

Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
