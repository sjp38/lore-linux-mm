Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2216B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 04:33:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so23447147pfv.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:33:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gc2si33935662pab.286.2016.09.20.01.33.51
        for <linux-mm@kvack.org>;
        Tue, 20 Sep 2016 01:33:51 -0700 (PDT)
Date: Tue, 20 Sep 2016 09:33:52 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC] Arm64 boot fail with numa enable in BIOS
Message-ID: <20160920083352.GA25614@arm.com>
References: <7618d76d-bfa8-d8aa-59aa-06f9d90c1a98@huawei.com>
 <20160919140709.GA17464@leverpostej>
 <cd53a1ae-e4ff-933c-4d1c-1ddaaa999a43@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd53a1ae-e4ff-933c-4d1c-1ddaaa999a43@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com

Hi Yisheng,

On Tue, Sep 20, 2016 at 11:29:24AM +0800, Yisheng Xie wrote:
> On 2016/9/19 22:07, Mark Rutland wrote:
> > On Mon, Sep 19, 2016 at 09:05:26PM +0800, Yisheng Xie wrote:
> > Can you modify the warning in cpumask.h to dump the bad CPU number? That
> > would make it fairly clear if that's the case.
> > 
> hi Mark,
> I dump the bad CPU number, it is 64,
> And the cpumask get from task is 00000000,00000000.
> 
> [    3.873044] select_task_rq: allowed 0, allow_cpumask 00000000,00000000
> [    3.879727] cpumask_check: cpu 64, nr_cpumask_bits:64, nr_cpu_ids= 64
> [    3.895989] ------------[ cut here ]------------
> [    3.900652] WARNING: CPU: 16 PID: 103 at ./include/linux/cpumask.h:122 try_to_wake_up+0x410/0x4ac

Can you look at this patch from David, please:

http://lists.infradead.org/pipermail/linux-arm-kernel/2016-September/458110.html

and offer a Tested-by if it fixes your problem?

Thanks,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
