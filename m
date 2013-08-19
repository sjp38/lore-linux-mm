Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D76516B0032
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 23:28:13 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id o17so4990046oag.21
        for <linux-mm@kvack.org>; Sun, 18 Aug 2013 20:28:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52118BE6.8060903@cn.fujitsu.com>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
	<20130812145016.GI15892@htj.dyndns.org>
	<5208FBBC.2080304@zytor.com>
	<20130812152343.GK15892@htj.dyndns.org>
	<52090D7F.6060600@gmail.com>
	<20130812164650.GN15892@htj.dyndns.org>
	<5209CEC1.8070908@cn.fujitsu.com>
	<520A02DE.1010908@cn.fujitsu.com>
	<CAE9FiQV2-OOvHZtPYSYNZz+DfhvL0e+h2HjMSW3DyqeXXvdJkA@mail.gmail.com>
	<520ADBBA.10501@cn.fujitsu.com>
	<1376593564.10300.446.camel@misato.fc.hp.com>
	<CAE9FiQVeMHAqZETP3d1PsPMk9-ZOXD=BD5HaTGFFO3dZenR0CA@mail.gmail.com>
	<520D89A7.7060802@cn.fujitsu.com>
	<CAE9FiQX0cxa4+2vtFpuCbH+Tb2YsMZTRRUwynbf_ogF8LN6Smg@mail.gmail.com>
	<52118BE6.8060903@cn.fujitsu.com>
Date: Sun, 18 Aug 2013 20:28:12 -0700
Message-ID: <CAE9FiQXq_k6+mj_MhAc0Lea89LPt0yyZMhr1nzpJuCvxqHysqQ@mail.gmail.com>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>, Tejun Heo <tj@kernel.org>, Tang Chen <imtangchen@gmail.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

On Sun, Aug 18, 2013 at 8:07 PM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
> On 08/16/2013 12:21 PM, Yinghai Lu wrote:
> ......
>
>>> By "put acpi_initrd_override in BRK", do you mean increase the BRK by
>>> default ?
>>
>>
>> Peter,
>>
>> Do you agree on extending BRK 256k to put copied override acpi tables?
>>
>> then we can find and copy them early in
>> arch/x86/kernel/head64.c::x86_64_start_kernel() or
>> arch/x86/kernel/head_32.S.
>
>
> Hi Yinghai,
>
> If we use BRK to store acpi tables, we don't need to setup page tables.
> If we do acpi_initrd_override() in setup_arch(), after early_ioremap is
> available, we don't need to split it into find & copy. It would be much
> easier.

we don't need to use early_ioremap if acpi_initrd_override is called in
arch/x86/kernel/head64.c::x86_64_start_kernel() or arch/x86/kernel/head_32.S.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
