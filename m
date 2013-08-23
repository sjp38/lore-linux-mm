Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 9A0986B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 17:52:52 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id i8so643641qcq.1
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 14:52:51 -0700 (PDT)
Date: Fri, 23 Aug 2013 17:52:43 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130823215243.GD11391@mtj.dyndns.org>
References: <1377202292.10300.693.camel@misato.fc.hp.com>
 <20130822202158.GD3490@mtj.dyndns.org>
 <1377205598.10300.715.camel@misato.fc.hp.com>
 <20130822212111.GF3490@mtj.dyndns.org>
 <1377209861.10300.756.camel@misato.fc.hp.com>
 <20130823130440.GC10322@mtj.dyndns.org>
 <1377274448.10300.777.camel@misato.fc.hp.com>
 <521793BB.9080605@gmail.com>
 <1377282543.10300.820.camel@misato.fc.hp.com>
 <CAD11hGzaK1Y1J7vQUOCQg8O767479qXQnYWm_72nPEK+E+TrHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAD11hGzaK1Y1J7vQUOCQg8O767479qXQnYWm_72nPEK+E+TrHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chen tang <imtangchen@gmail.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

Hello,

On Sat, Aug 24, 2013 at 05:37:48AM +0800, chen tang wrote:
> We have read the comments from Yinghai. Reordering relocated_initrd and
> reserve_crashkernel is doable, and the most difficult part is change the page
> tables initialization logic. And as Zhang has mentioned above, we are not sure
> if this could be acceptable.

Maybe I'm missing something but why is that so hard?  All it does is
allocating memory in a different place.  Why is that so complicated?
Can somebody please elaborate the issues here?  If it is actually
hairy, where does the hairiness come from?  Is it an inherent problem
or just an issue with how the code is organized currently?

> Actually I also stand with Toshi that we should get SRAT earlier. This
> will solve
> memory hotplug issue, and also the following local page table problem.

Do you mind responding to the points raised in the discussion?  I
really don't wnat to repeat the whole discussion anew and your
statements don't really add anything new.

> And as tj concerned about the stability of the kernel boot sequence, then how
> about this:

I guess my answer remains the same.  Why?  What actual benefits does
doing so buy us and why is changing the allocation direction, which
conceptually is extremely simple, so complicated?  What you guys are
trying to do adds significant amount of complexity and convolution,
which in itself doesn't necessarily disqualify the changes but it
needs good enough justifications.

I get that you guys want it but I still fail to see why.  It *can't*
be proper solution to the hotplug issue.  We don't want earlyprintk to
involve huge chunk of logic and the benefits of node-affine page
tables for kernel linear mapping seem dubious.  So, what do we gain by
doing this?  What am I missing here?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
