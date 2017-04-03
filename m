Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63BAC6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 06:56:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a72so137347202pge.10
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 03:56:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f21si13974865pgh.242.2017.04.03.03.56.51
        for <linux-mm@kvack.org>;
        Mon, 03 Apr 2017 03:56:51 -0700 (PDT)
Date: Mon, 3 Apr 2017 11:56:29 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Bad page state splats on arm64, v4.11-rc{3,4}
Message-ID: <20170403105629.GB18905@leverpostej>
References: <20170331175845.GE6488@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170331175845.GE6488@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, will.deacon@arm.com, catalin.marinas@arm.com, punit.agrawal@arm.com

On Fri, Mar 31, 2017 at 06:58:45PM +0100, Mark Rutland wrote:
> Hi,
> 
> I'm seeing intermittent bad page state splats on arm64 with 4.11-rc3 and
> v4.11-rc4. I have not tested earlier kernels, or other architectures.
> 
> So far, it looks like the flags are always bad in the same
> way:
> 
> 	bad because of flags: 0x80(waiters)
> 
> ... though I don't know if that's definitely the case for splat 4, the
> BUG at mm/page_alloc.c:800.
> 
> I see this in QEMU VMs launched by Syzkaller, triggering once every few
> hours. So far, I have not been able to reproduce the issue in any other
> way (including using syz-repro).

It looks like this may be an issue with the arm64 HUGETLB code.

I wasn't able to trigger the issue over the weekend on a kernel with
HUGETLBFS disabled. There are known issues with our handling of
contiguous entries, and this might be an artefact of that.

I'll see if I can narrow this down any further.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
