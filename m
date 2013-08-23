Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 042D56B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 14:26:41 -0400 (EDT)
Message-Id: <201308231825.r7NIPQl5015165@mail.zytor.com>
In-Reply-To: <CAE9FiQXZ610BrVaXoxY70NS3CaSku7mcVFx+x34-jpYUkG2rdQ@mail.gmail.com>
References: <20130821204041.GC2436@htj.dyndns.org> <1377124595.10300.594.camel@misato.fc.hp.com> <20130822033234.GA2413@htj.dyndns.org> <1377186729.10300.643.camel@misato.fc.hp.com> <20130822183130.GA3490@mtj.dyndns.org> <1377202292.10300.693.camel@misato.fc.hp.com> <20130822202158.GD3490@mtj.dyndns.org> <1377205598.10300.715.camel@misato.fc.hp.com> <20130822212111.GF3490@mtj.dyndns.org> <1377209861.10300.756.camel@misato.fc.hp.com> <20130823130440.GC10322@mtj.dyndns.org> <1377274448.10300.777.camel@misato.fc.hp.com> <521793BB.9080605@gmail.com> <CAE9FiQXZ610BrVaXoxY70NS3CaSku7mcVFx+x34-jpYUkG2rdQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Fri, 23 Aug 2013 20:25:13 +0200
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Tejun Heo <tj@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang.Yanfei@zytor.com

<zhangyanfei@cn.fujitsu.com>,"yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>,the arch/x86 maintainers <x86@kernel.org>,"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,Linux MM <linux-mm@kvack.org>,ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Message-ID: <aad28f9f-be10-43d8-bb98-e28d46101c44@email.android.com>

BRK makes sense as long as you can set a sane O(1) size limit.

Yinghai Lu <yinghai@kernel.org> wrote:
>[trimmed the CC list, assume too long list will not go through LKML]
>
>On Fri, Aug 23, 2013 at 9:54 AM, Zhang Yanfei
><zhangyanfei.yes@gmail.com> wrote:
>
>
>
>> By saying TJ's suggestion, you mean, we will let memblock to control
>the
>> behaviour, that said, we will do early allocations near the kernel
>image
>> range before we get the SRAT info?
>
>put the acpi override table in BRK, we still need ok from HPA.
>I have impression that he did not like it, so want to confirm from him.
>
>>
>> If so, yeah, we have been working on this direction. By doing this,
>we may
>> have two main changes:
>>
>> 1. change some of memblock's APIs to make it have the ability to
>allocate
>>    memory from low address.
>> 2. setup kernel page table down-top. Concretely, we first map the
>memory
>>    just after the kernel image to the top, then, we map 0 - kernel
>image end.
>
>how about kexec/kdump ?
>
>when load high with kexec/dump, the second kernel could be very high
>near
>TOHM.
>
>>
>> Do you guys think this is reasonable and acceptable?
>
>current boot flow that need to have all cpu and mem and pci discovered
>are not scalable.
>
>for numa system, we should boot system with cpu/mem/pci in PXM(X) only.
>and assume that PXM are not hot-removed later.
>Later during booting late stage hot add other PXM in parallel.
>
>That case, we could reduce boot time, and also could solve other PXM
>hotplug problem.
>
>Thanks
>
>Yinghai

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
