Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9466B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 11:44:09 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so4748918pdj.36
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:44:09 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so4730130pbc.37
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:44:05 -0700 (PDT)
Message-ID: <5241B32E.3090803@gmail.com>
Date: Tue, 24 Sep 2013 23:43:42 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mem-hotplug: Introduce movablenode boot option
References: <524162DA.30004@cn.fujitsu.com> <5241655E.1000007@cn.fujitsu.com> <20130924124121.GG2366@htj.dyndns.org> <5241944B.4050103@gmail.com> <5241AEC0.6040505@gmail.com> <20130924153259.GM2366@htj.dyndns.org>
In-Reply-To: <20130924153259.GM2366@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 09/24/2013 11:32 PM, Tejun Heo wrote:
> Hello,
> 
> On Tue, Sep 24, 2013 at 11:24:48PM +0800, Zhang Yanfei wrote:
>> I am now preparing the v5 version. Only in this patch we haven't come to an
>> agreement. So as for the boot option name, after my explanation, do you still
>> have the objection? Or you could suggest a good name for us, that'll be
>> very thankful:)
> 
> No particular idea and my concern about the name isn't very strong.
> It just doesn't seem like a good name to me.  It's a bit obscure and
> we may want to do more things for hotplug later which may not fit the
> param name.  If you guys think it's good enough, please go ahead.
> 

Thanks very much!

I have addressed your comments and finish the v5 version. Please help
checking them again after I send them to the community. Thanks.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
