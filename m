Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id DA7AF6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:23:33 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so4557576pdj.20
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:23:33 -0700 (PDT)
Received: by mail-qc0-f181.google.com with SMTP id q4so3021356qcx.40
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:23:30 -0700 (PDT)
Date: Tue, 24 Sep 2013 09:23:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/6] memblock: Introduce bottom-up allocation mode
Message-ID: <20130924132327.GH2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <524163CF.3010303@cn.fujitsu.com>
 <20130924121725.GC2366@htj.dyndns.org>
 <524190DC.4060605@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524190DC.4060605@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On Tue, Sep 24, 2013 at 09:17:16PM +0800, Zhang Yanfei wrote:
> > Maybe just print warning only on the first failure?
> 
> Hmmm... This message is for each memblock allocation, that said, if the
> allocation this time fails, it prints the message and we use so called top-down.
> But next time, we still use bottom up first again.
> 
> Did you mean if we fail on one bottom-up allocation, then we never try
> bottom-up again and will always use top-down? 

Nope, it's just that it might end up printing something for each alloc
which can end up flooding console / log.  The first failure is the
most interesting and pretty much defeats the purpose of the whole
thing after all.  If it's expected to fail very rarely, I'd just stick
in WARN_ONCE() there as the stack trace would be interesting too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
