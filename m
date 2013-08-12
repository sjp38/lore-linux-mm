Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 476BC6B0044
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:12:19 -0400 (EDT)
Message-ID: <52094F93.3010203@zytor.com>
Date: Mon, 12 Aug 2013 14:11:47 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org> <5208FBBC.2080304@zytor.com> <20130812152343.GK15892@htj.dyndns.org> <52090D7F.6060600@gmail.com> <20130812164650.GN15892@htj.dyndns.org> <52092811.3020105@gmail.com> <20130812202029.GB8288@mtj.dyndns.org> <3908561D78D1C84285E8C5FCA982C28F31CB74A1@ORSMSX106.amr.corp.intel.com> <20130812205456.GC8288@mtj.dyndns.org> <52094C30.7070204@zytor.com> <CAE9FiQVb2Z+9kJ_gK22KJZ_hm7yVfM910mxaj+njcWTMf4f+yw@mail.gmail.com>
In-Reply-To: <CAE9FiQVb2Z+9kJ_gK22KJZ_hm7yVfM910mxaj+njcWTMf4f+yw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Tang Chen <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, "Moore, Robert" <robert.moore@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "trenn@suse.de" <trenn@suse.de>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>

On 08/12/2013 02:06 PM, Yinghai Lu wrote:
> 
> should use BRK for safe if the buffer is not too big. need bootloader
> will have kernel run-time size range in same node ram.
> 

The bootloader typically won't know.

>>
>> Again, how much memory are we talking about here?
> 
> page tables, buffer for slit table, buffer for double
> memblock.reserved, override acpi tables.
> 
> looks like it is needing several mega bytes, esp someone using 4k page
> mapping for debug purpose.
> 

We need to set a careful limit, then.  "Several megabytes" could be a
problem causing a boot failure on a small memory machine if we extend
the BRK too much... obviously, a too-small BRK can fail on large systems.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
