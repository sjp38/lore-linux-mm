Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id C167D6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 17:11:26 -0400 (EDT)
Received: by mail-gh0-f181.google.com with SMTP id z12so2624656ghb.26
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 14:11:25 -0700 (PDT)
Date: Tue, 23 Jul 2013 17:11:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 17/21] page_alloc, mem-hotplug: Improve movablecore to
 {en|dis}able using SRAT.
Message-ID: <20130723211119.GW21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-18-git-send-email-tangchen@cn.fujitsu.com>
 <20130723210435.GV21100@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130723210435.GV21100@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Tue, Jul 23, 2013 at 05:04:35PM -0400, Tejun Heo wrote:
> On Fri, Jul 19, 2013 at 03:59:30PM +0800, Tang Chen wrote:
> ...
> > Users can specify "movablecore=acpi" in kernel commandline to enable this
> > functionality. For those who don't use memory hotplug or who don't want
> > to lose their NUMA performance, just don't specify anything. The kernel
> > will work as before.
> 
> The param name is pretty obscure and why would the user care where

I mean, having movable zone is required for having any decent chance
of memory hotplug and movable zone implies worse affinity for kernel
data structures, so there's no point in distinguishing memory hotplug
enable/disable and this, right?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
