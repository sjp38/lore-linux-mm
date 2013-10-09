Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9616B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 15:24:07 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so1407299pdj.20
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:24:06 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id if17so882795vcb.18
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:24:04 -0700 (PDT)
Date: Wed, 9 Oct 2013 15:23:56 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131009192356.GB5592@mtj.dyndns.org>
References: <524E2032.4020106@gmail.com>
 <524E2127.4090904@gmail.com>
 <5251F9AB.6000203@zytor.com>
 <525442A4.9060709@gmail.com>
 <20131009164449.GG22495@htj.dyndns.org>
 <CAE9FiQXhW2BacXUjQLK8TpcvhHAediuCntVR13sKGUuq_+=ymw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQXhW2BacXUjQLK8TpcvhHAediuCntVR13sKGUuq_+=ymw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello, Yinghai.

On Wed, Oct 09, 2013 at 12:10:34PM -0700, Yinghai Lu wrote:
> > I still feel quite uneasy about pulling SRAT parsing and ACPI initrd
> > overriding into early boot.
> 
> for your reconsidering to parse srat early, I refresh that old patchset
> at
> 
> https://git.kernel.org/cgit/linux/kernel/git/yinghai/linux-yinghai.git/log/?h=for-x86-mm-3.13
> 
> actually looks one-third or haf patches already have your ack.

Yes, but those acks assume that the overall approach is a good idea.
The biggest issue that I have with the approach is that it is invasive
and modifies basic structure for an inherently kludgy solution for a
quite niche problem.  The benefit / cost ratio still seems quite off
to me - we're making a lot of general changes to serve something very
specialized, which might not even stay relevant for long time.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
