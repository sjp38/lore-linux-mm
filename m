Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 93E026B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 11:33:06 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so4707606pbc.11
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:33:06 -0700 (PDT)
Received: by mail-ye0-f176.google.com with SMTP id m4so1759585yen.35
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 08:33:03 -0700 (PDT)
Date: Tue, 24 Sep 2013 11:32:59 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 6/6] mem-hotplug: Introduce movablenode boot option
Message-ID: <20130924153259.GM2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <5241655E.1000007@cn.fujitsu.com>
 <20130924124121.GG2366@htj.dyndns.org>
 <5241944B.4050103@gmail.com>
 <5241AEC0.6040505@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5241AEC0.6040505@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

Hello,

On Tue, Sep 24, 2013 at 11:24:48PM +0800, Zhang Yanfei wrote:
> I am now preparing the v5 version. Only in this patch we haven't come to an
> agreement. So as for the boot option name, after my explanation, do you still
> have the objection? Or you could suggest a good name for us, that'll be
> very thankful:)

No particular idea and my concern about the name isn't very strong.
It just doesn't seem like a good name to me.  It's a bit obscure and
we may want to do more things for hotplug later which may not fit the
param name.  If you guys think it's good enough, please go ahead.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
