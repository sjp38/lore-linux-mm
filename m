Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFB66B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 06:46:35 -0400 (EDT)
Received: by mail-yh0-f41.google.com with SMTP id i57so2022963yha.14
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:46:34 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id r22si4486191yhk.32.2014.04.24.03.46.34
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 03:46:34 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:46:24 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH V2 0/5] Huge pages for short descriptors on ARM
Message-ID: <20140424104624.GD19564@arm.com>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
 <20140424102229.GA28014@linaro.org>
 <20140424103639.GC19564@arm.com>
 <20140424104232.GK26756@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140424104232.GK26756@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Steve Capper <steve.capper@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "robherring2@gmail.com" <robherring2@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On Thu, Apr 24, 2014 at 11:42:32AM +0100, Russell King - ARM Linux wrote:
> On Thu, Apr 24, 2014 at 11:36:39AM +0100, Will Deacon wrote:
> > I guess I'm after some commitment that this is (a) useful to somebody and
> > (b) going to be tested regularly, otherwise it will go the way of things
> > like big-endian, where we end up carrying around code which is broken more
> > often than not (although big-endian is more self-contained).
> 
> It may be something worth considering adding to my nightly builder/boot
> testing, but I suspect that's impractical as it probably requires a BE
> userspace, which would then mean that the platform can't boot LE.
> 
> I suspect that we will just have to rely on BE users staying around and
> reporting problems when they occur.

Indeed. Marc and I have BE guests running under kvmtool on an LE host, so
that's what I've been using (then a BE busybox can sit in the host
filesystem and be passed via something like 9pfs).

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
