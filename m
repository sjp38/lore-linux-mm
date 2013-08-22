Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 585CF6B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 16:35:36 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id bv4so597731qab.15
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 13:35:35 -0700 (PDT)
Date: Thu, 22 Aug 2013 16:35:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130822203529.GE3490@mtj.dyndns.org>
References: <1377113503.10300.492.camel@misato.fc.hp.com>
 <20130821195410.GA2436@htj.dyndns.org>
 <1377116968.10300.514.camel@misato.fc.hp.com>
 <20130821204041.GC2436@htj.dyndns.org>
 <1377124595.10300.594.camel@misato.fc.hp.com>
 <20130822033234.GA2413@htj.dyndns.org>
 <1377186729.10300.643.camel@misato.fc.hp.com>
 <20130822183130.GA3490@mtj.dyndns.org>
 <1377202292.10300.693.camel@misato.fc.hp.com>
 <20130822202158.GD3490@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130822202158.GD3490@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

A bit of addition.

On Thu, Aug 22, 2013 at 04:21:58PM -0400, Tejun Heo wrote:
> That works if such half solution eventually leads to the full
> solution.  This is just a distraction.  You are already too late in
> the boot sequence.  It doesn't even qualify as a half solution.  It's
> like obsessing about a speck on your shirt without your trousers on.
> If you want to solve this, do that from a place where it actually is
> solvable.

Seriously, what's the end game here?  How do you guys see this
eventually reaching full solution?  If you don't see that and this
kinda-sorta-working solution is fine, then that's fine too but we
aren't gonna make a lot of invasive changes for that.  If you can at
least envision the full solution, please try to fit this effort into
the bigger picture.

In all possible solutions that I can think of, there needs to be
earlier handling of SRAT informtaion before the kernel proper starts
executing be that either the actual bootloader or earlier kernel
serving as kexec host.  If a proper solution needs such processing
earlier anyway, it can set up things so that either the default
booting behavior doesn't harm hotpluggability or feed the necessary
information to the kernel.  In both cases, doing ACPI super early in
the booting kernel doesn't buy us anything.

So, then, what the hell are we doing here with all these relocations,
careful double execution of the same code from different execution
contexts, worrying about initrd firmware override even before the
kernel page table is set up?  If we're doing all those to just make
the temporary half-assed-anyway solution minutely better, that's just
plain stupid.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
