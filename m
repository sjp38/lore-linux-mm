Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D26456B0038
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 00:23:10 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so8165920pab.25
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 21:23:10 -0700 (PDT)
Received: by mail-ea0-f172.google.com with SMTP id r16so3702559ead.3
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 21:23:06 -0700 (PDT)
Date: Tue, 8 Oct 2013 06:23:02 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH part1 v6 0/6] x86, memblock: Allocate memory near kernel
 image before SRAT parsed
Message-ID: <20131008042302.GA14353@gmail.com>
References: <524E2032.4020106@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524E2032.4020106@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>


* Zhang Yanfei <zhangyanfei.yes@gmail.com> wrote:

> Hello, here is the v6 version. Any comments are welcome!

Ok, I think this is as good as this feature can get without hardware 
support.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
