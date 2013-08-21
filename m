Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 8C8436B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 16:30:57 -0400 (EDT)
Message-ID: <1377116968.10300.514.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 21 Aug 2013 14:29:28 -0600
In-Reply-To: <20130821195410.GA2436@htj.dyndns.org>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
	 <20130821130647.GB19286@mtj.dyndns.org> <5214D60A.2090309@gmail.com>
	 <20130821153639.GA17432@htj.dyndns.org>
	 <1377113503.10300.492.camel@misato.fc.hp.com>
	 <20130821195410.GA2436@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello Tejun,

On Wed, 2013-08-21 at 15:54 -0400, Tejun Heo wrote:
> On Wed, Aug 21, 2013 at 01:31:43PM -0600, Toshi Kani wrote:
> > Well, there is reason why we have earlyprintk feature today.  So, let's
> > not debate on this feature now.  There was previous attempt to support
> 
> Are you saying the existing earlyprintk automatically justifies
> addition of more complex mechanism?  The added complex of course
> should be traded off against the benefits of gaining ACPI based early
> boot.  You aren't gonna suggest implementing netconsole based
> earlyprintk, right?

Platforms vendors (which care Linux) need to support the existing Linux
features.  This means that they have to implement legacy interfaces on
x86 until the kernel supports an alternative method.  For instance, some
platforms are legacy-free and do not have legacy COM ports.  These ACPI
tables were defined so that non-legacy COM ports can be described and
informed to the OS.  Without this support, such platforms may have to
emulate the legacy COM ports for Linux, or drop Linux support.

> > this feature with ACPI tables below.  As described, it had the same
> > ordering issue.
> > 
> > https://lkml.org/lkml/2012/10/8/498
> > 
> > There is a basic problem that when we try to use ACPI tables that
> > extends or replaces legacy interfaces (ex. SRAT extending e820), we hit
> > this ordering issue because ACPI is not available as early as the legacy
> > interfaces.
> 
> Do we even want ACPI parsing and all that that early?  Parsing SRAT
> early doesn't buy us much and I'm not sure whether adding ACPI
> earlyprintk would increase or decrease debuggability during earlyboot.
> It adds whole lot more code paths where things can go wrong while the
> basic execution environment is unstable.  Why do that?

I think the kernel boot-up sequence should be designed in such a way
that can support legacy-free and/or NUMA platforms properly.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
