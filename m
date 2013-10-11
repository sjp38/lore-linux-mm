Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D96246B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 02:33:07 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so3702062pdj.6
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 23:33:07 -0700 (PDT)
Received: by mail-ee0-f47.google.com with SMTP id d49so1637579eek.34
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 23:33:03 -0700 (PDT)
Date: Fri, 11 Oct 2013 08:33:00 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131011063300.GA9429@gmail.com>
References: <524E2032.4020106@gmail.com>
 <524E2127.4090904@gmail.com>
 <5251F9AB.6000203@zytor.com>
 <525442A4.9060709@gmail.com>
 <20131009164449.GG22495@htj.dyndns.org>
 <CAE9FiQXhW2BacXUjQLK8TpcvhHAediuCntVR13sKGUuq_+=ymw@mail.gmail.com>
 <20131009192356.GB5592@mtj.dyndns.org>
 <CAE9FiQWpwp4bTEWEYw3-CW9xF5s_zJAayJrBC_buBC7-nd=7KA@mail.gmail.com>
 <525790E4.3060806@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <525790E4.3060806@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>


* Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:

> Hello yinghai,
> 
> I know your opinion but take code modification as an example seems like 
> it doesn't stand. More code doesn't mean more complexity......

I think you forgot to reply to this point:

> > For long term to keep the code more maintainable, We really should go 
> > though parse srat table early.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
