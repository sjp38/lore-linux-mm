Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4A06B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:54:26 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so3001854pab.6
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 09:54:26 -0700 (PDT)
Message-ID: <1381423840.24268.70.camel@misato.fc.hp.com>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 10 Oct 2013 10:50:40 -0600
In-Reply-To: <20131010164623.GD13276@htj.dyndns.org>
References: <20131009164449.GG22495@htj.dyndns.org>
	 <52558EEF.4050009@gmail.com> <20131009192040.GA5592@mtj.dyndns.org>
	 <1381352311.5429.115.camel@misato.fc.hp.com>
	 <20131009211136.GH5592@mtj.dyndns.org>
	 <1381363135.5429.138.camel@misato.fc.hp.com>
	 <20131010010029.GA10900@mtj.dyndns.org>
	 <1381415809.24268.40.camel@misato.fc.hp.com>
	 <20131010153518.GB13276@htj.dyndns.org>
	 <1381422249.24268.68.camel@misato.fc.hp.com>
	 <20131010164623.GD13276@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J .
 Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello,

On Thu, 2013-10-10 at 12:46 -0400, Tejun Heo wrote:
> On Thu, Oct 10, 2013 at 10:24:09AM -0600, Toshi Kani wrote:
> > > We're going round and round.  You're saying that using SRAT isn't
> > > worse than what came before while failing to illustrate how committing
> > > to invasive changes would eventually lead to something better.  "it
> > > isn't worse" isn't much of an argument.
> > 
> > We did avoid moving up the ACPI table init function per your suggestion.
> > I guess I do not understand why you still concerned about using SRAT...
> 
> As you wrote above, SRAT is not enough to support device granularity.
> We need to parse the device hierarchy too before setting up page
> tables and one of the previous arguments was "it's only SRAT".  It
> doesn't instill confidence when there doesn't seem to be much long
> term planning going on especially as the general quality of the
> patches isn't particularly high.  I find it difficult to believe that
> this effort as it currently stands is likely to reach full solution
> and as such it feels much safer to opt for a simpler, less dangerous
> approach for immedate use, for which either approach doesn't make much
> of difference.

Can you elaborate why we need to parse the device hierarchy before
setting up page tables?

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
