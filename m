Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B1EC26B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 23:32:39 -0400 (EDT)
Received: by mail-qe0-f52.google.com with SMTP id a11so800900qen.25
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:32:38 -0700 (PDT)
Date: Wed, 21 Aug 2013 23:32:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130822033234.GA2413@htj.dyndns.org>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130821130647.GB19286@mtj.dyndns.org>
 <5214D60A.2090309@gmail.com>
 <20130821153639.GA17432@htj.dyndns.org>
 <1377113503.10300.492.camel@misato.fc.hp.com>
 <20130821195410.GA2436@htj.dyndns.org>
 <1377116968.10300.514.camel@misato.fc.hp.com>
 <20130821204041.GC2436@htj.dyndns.org>
 <1377124595.10300.594.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377124595.10300.594.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Wed, Aug 21, 2013 at 04:36:35PM -0600, Toshi Kani wrote:
> I agree that ACPI is rather complicated stuff.  But in my experience,
> the majority complication comes from ACPI namespace and methods, not
> from ACPI tables.  Do you really think ACPI table init is that risky?  I
> consider ACPI tables are part of the minimum config info, esp. for
> legacy-free platforms.

It's just that we're talking about the very first stage of boot.  We
really don't do much there and pulling in ACPI code into that stage is
a lot by comparison.  If that's gonna happen, it needs pretty strong
justification.

> earlyprintk is just another example to this SRAT issue.  The local page
> table is yet another example.  My hope here is for us to be able to
> utilize ACPI tables properly without hitting this kind of ordering
> issues again and again, which requires considerable time & effort to
> address.

So, the two things brought up at this point are early parsing of SRAT,
which can't really solve the problem at hand anyway, and earlyprintk
which should be implemented in minimal way which is not activated
unless specifically enabled with earlyprintk boot param.  Neither
seems to justify pulling in full ACPI into early boot, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
