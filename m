Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6349F82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 15:11:13 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so108140523pac.3
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:11:13 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id r7si2245958pap.71.2015.11.06.12.11.12
        for <linux-mm@kvack.org>;
        Fri, 06 Nov 2015 12:11:12 -0800 (PST)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 7397920561
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 20:11:11 +0000 (UTC)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D1BE9204EA
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 20:11:09 +0000 (UTC)
Received: by wiva10 with SMTP id a10so2305997wiv.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:11:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+Jeg-Cwc7Tr8UeY9vkJLudw07+b=m0h-d9GuSyKiO4QA@mail.gmail.com>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
	<20151105094615.GP8644@n2100.arm.linux.org.uk>
	<563B81DA.2080409@redhat.com>
	<20151105162719.GQ8644@n2100.arm.linux.org.uk>
	<563BFCC4.8050705@redhat.com>
	<CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
	<563CF510.9080506@redhat.com>
	<CAGXu5jKLgL0Kt5xCWv-3ZUX94m1DNXLqsEDQKHoq7T=m6P7tvQ@mail.gmail.com>
	<CAGXu5j+Jeg-Cwc7Tr8UeY9vkJLudw07+b=m0h-d9GuSyKiO4QA@mail.gmail.com>
Date: Fri, 6 Nov 2015 12:11:08 -0800
Message-ID: <CAMAWPa9XvdS+dF78c7Fgs4ekRy7wVnfFT=0A5NLpu0UYaqV7fA@mail.gmail.com>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
From: Kevin Hilman <khilman@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: info@kernelci.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Tyler Baker <tyler.baker@linaro.org>

On Fri, Nov 6, 2015 at 11:12 AM, Kees Cook <keescook@chromium.org> wrote:

[...]

> Hi Kevin and Kernel CI folks,
>
> Could lkdtm get added to the kernel-CI workflows? Extracting and
> validating Oops details when poking lkdtm would be extremely valuable
> for these cases. :)

Yeah, we can add that.

What arches should we expect this to be working on?  For starters
we'll get builds going with CONFIG_LKDTM=y, and then start looking at
adding the tests on arches that should work.

Thes will be an interesting failure modes to catch because a kernel
panic is actually a PASS, and a failure to panic is a FAIL.  :)

Kevin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
