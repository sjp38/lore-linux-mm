Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 84B5C6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 12:15:39 -0400 (EDT)
Message-ID: <1377274448.10300.777.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 23 Aug 2013 10:14:08 -0600
In-Reply-To: <20130823130440.GC10322@mtj.dyndns.org>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Fri, 2013-08-23 at 09:04 -0400, Tejun Heo wrote:
> On Thu, Aug 22, 2013 at 04:17:41PM -0600, Toshi Kani wrote:
> > I am relatively new to Linux, so I am not a good person to elaborate
> > this.  From my experience on other OS, huge pages helped for the kernel,
> > but did not necessarily help user applications.  It depended on
> > applications, which were not niche cases.  But Linux may be different,
> > so I asked since you seemed confident.  I'd appreciate if you can point
> > us some data that endorses your statement.
> 
> We are talking about the kernel linear mapping which is created during
> early boot, so if it's available and useable there's no reason not to
> use it.  Exceptions would be earlier processors which didn't do 1G
> mappings or e820 maps with a lot of holes.  For CPUs used in NUMA
> configurations, the former has been history for a bit now.  Can't be
> sure about the latter but it'd be surprising for that to affect large
> amount of memory in the systems that are of interest here.  Ooh, that
> reminds me that we probably wanna go back to 1G + MTRR mapping under
> 4G.  We're currently creating a lot of mapping holes.

Thanks for the explanation.

> > My worry is that the code is unlikely tested with the special logic when
> > someone makes code changes to the page tables.  Such code can easily be
> > broken in future.
> 
> Well, I wouldn't consider flipping the direction of allocation to be
> particularly difficult to get right especially when compared to
> bringing in ACPI tables into the mix.
> 
> > To answer your other question/email, I believe Tang's next step is to
> > support local page tables.  This is why we think pursing SRAT earlier is
> > the right direction.
> 
> Given 1G mappings, is that even a worthwhile effort?  I'm getting even
> more more skeptical.

With 1G mappings, I agree that it won't make much difference.

I still think acpi table info should be available earlier, but I do not
think I can convince you on this.  This can be religious debate.

Tang, what do you think?  Are you OK to try Tejun's suggestion as well? 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
