Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 72E0C6B0033
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 06:27:19 -0400 (EDT)
Received: by mail-ve0-f178.google.com with SMTP id ox1so485182veb.37
        for <linux-mm@kvack.org>; Fri, 26 Jul 2013 03:27:18 -0700 (PDT)
Date: Fri, 26 Jul 2013 06:27:14 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 14/21] x86, acpi, numa: Reserve hotpluggable memory at
 early time.
Message-ID: <20130726102714.GC30786@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-15-git-send-email-tangchen@cn.fujitsu.com>
 <20130723205557.GS21100@mtj.dyndns.org>
 <20130723213212.GA21100@mtj.dyndns.org>
 <51F089C1.4010402@cn.fujitsu.com>
 <20130725151719.GE26107@mtj.dyndns.org>
 <51F1F0E0.7040800@cn.fujitsu.com>
 <20130726102609.GB30786@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130726102609.GB30786@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 26, 2013 at 06:26:09AM -0400, Tejun Heo wrote:
> > So how about this.
> > 1. Introduce a new global list used to store hotpluggable regions.
> > 2. On acpi side, find and fulfill the list.
> > 3. On memblock side, make the default allocation function stay away from
> >    these regions.
> 
> I was thinking more along the line of
> 
> 1. Mark hotpluggable regions with a flag in memblock.
> 2. On ACPI side, find and mark hotpluggable regions.
> 3. Make memblock avoid giving out hotpluggable regions for normal
>    allocations.

But adding new regions array is more convenient / cleaner, that's fine
too.  Those arrays are dynamically sized anyway.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
