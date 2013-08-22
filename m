Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4E38E6B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 15:40:24 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so2256886pbc.12
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 12:40:23 -0700 (PDT)
Message-ID: <52166909.6080104@gmail.com>
Date: Fri, 23 Aug 2013 03:39:53 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
References: <20130821130647.GB19286@mtj.dyndns.org> <5214D60A.2090309@gmail.com> <20130821153639.GA17432@htj.dyndns.org> <1377113503.10300.492.camel@misato.fc.hp.com> <20130821195410.GA2436@htj.dyndns.org> <1377116968.10300.514.camel@misato.fc.hp.com> <20130821204041.GC2436@htj.dyndns.org> <1377124595.10300.594.camel@misato.fc.hp.com> <20130822033234.GA2413@htj.dyndns.org> <1377186729.10300.643.camel@misato.fc.hp.com> <20130822183130.GA3490@mtj.dyndns.org>
In-Reply-To: <20130822183130.GA3490@mtj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello tejun,

On 08/23/2013 02:31 AM, Tejun Heo wrote:
> Hello,
> 
> On Thu, Aug 22, 2013 at 09:52:09AM -0600, Toshi Kani wrote:
>> I understand that you are concerned about stability of the ACPI stuff,
>> which I think is a valid point, but most of (if not all) of the
>> ACPI-related issues come from ACPI namespace/methods, which is a very
>> different thing.  Please do not mix up those two.  The ACPI
> 
> I have no objection to implementing self-conftained earlyprintk
> support.  If that's all you want to do, please go ahead but do not
> pull in initrd override or ACPICA into it.
> 
>> namespace/methods stuff remains the same and continues to be initialized
>> at very late in the boot sequence.
>>
>> What's making the patchset complicated is acpi_initrd_override(), which
>> is intended for developers and allows overwriting ACPI bits at their own
>> risk.  This feature won't be used by regular users. 
> 
> Yeah, please forget about that in earlyboot.  It doesn't make any
> sense to fiddle with initrd that early during boot.

What do you mean by "earlyboot"? And also in your previous mail, I am also
a little confused by what you said "the very first stage of boot". Does
this mean the stage we are in head_32 or head64.c?

If so, could we just do something just as Yinghai did before, that is, Split
acpi_override into 2 parts: find and copy. And in "earlyboot", we just do
the find, and I think that is less of risk. Or we can just do ACPI override
earlier in setup_arch(), not pulling this process that early during boot?

Thanks

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
