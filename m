Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2416B0036
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:55:31 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so2814809pbc.7
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 09:55:30 -0700 (PDT)
Received: by mail-qe0-f42.google.com with SMTP id gc15so2270510qeb.1
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 09:55:28 -0700 (PDT)
Date: Thu, 10 Oct 2013 12:55:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131010165522.GE13276@htj.dyndns.org>
References: <20131009192040.GA5592@mtj.dyndns.org>
 <1381352311.5429.115.camel@misato.fc.hp.com>
 <20131009211136.GH5592@mtj.dyndns.org>
 <1381363135.5429.138.camel@misato.fc.hp.com>
 <20131010010029.GA10900@mtj.dyndns.org>
 <1381415809.24268.40.camel@misato.fc.hp.com>
 <20131010153518.GB13276@htj.dyndns.org>
 <1381422249.24268.68.camel@misato.fc.hp.com>
 <20131010164623.GD13276@htj.dyndns.org>
 <1381423840.24268.70.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381423840.24268.70.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Thu, Oct 10, 2013 at 10:50:40AM -0600, Toshi Kani wrote:
> Can you elaborate why we need to parse the device hierarchy before
> setting up page tables?

How else can one put the page tables on the "local device"?  Am I
missing something?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
