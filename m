Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 626FE6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 14:30:36 -0400 (EDT)
Message-ID: <1377282543.10300.820.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 23 Aug 2013 12:29:03 -0600
In-Reply-To: <521793BB.9080605@gmail.com>
References: <20130821204041.GC2436@htj.dyndns.org>
	  <1377124595.10300.594.camel@misato.fc.hp.com>
	  <20130822033234.GA2413@htj.dyndns.org>
	  <1377186729.10300.643.camel@misato.fc.hp.com>
	  <20130822183130.GA3490@mtj.dyndns.org>
	  <1377202292.10300.693.camel@misato.fc.hp.com>
	  <20130822202158.GD3490@mtj.dyndns.org>
	  <1377205598.10300.715.camel@misato.fc.hp.com>
	  <20130822212111.GF3490@mtj.dyndns.org>
	  <1377209861.10300.756.camel@misato.fc.hp.com>
	  <20130823130440.GC10322@mtj.dyndns.org>
	 <1377274448.10300.777.camel@misato.fc.hp.com> <521793BB.9080605@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello Zhang,

On Sat, 2013-08-24 at 00:54 +0800, Zhang Yanfei wrote:
> > Tang, what do you think?  Are you OK to try Tejun's suggestion as well? 
> > 
> 
> By saying TJ's suggestion, you mean, we will let memblock to control the
> behaviour, that said, we will do early allocations near the kernel image
> range before we get the SRAT info?

Right.

> If so, yeah, we have been working on this direction. 

Great!

> By doing this, we may
> have two main changes:
> 
> 1. change some of memblock's APIs to make it have the ability to allocate
>    memory from low address.
> 2. setup kernel page table down-top. Concretely, we first map the memory
>    just after the kernel image to the top, then, we map 0 - kernel image end.
> 
> Do you guys think this is reasonable and acceptable?

Have you also looked at Yinghai's comments below?

http://www.spinics.net/lists/linux-mm/msg61362.html

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
