Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 39D156B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 21:06:02 -0400 (EDT)
Received: by mail-ye0-f174.google.com with SMTP id m9so1156087yen.33
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:06:01 -0700 (PDT)
Date: Mon, 17 Jun 2013 18:05:48 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 11/22] x86, mm, numa: Call
 numa_meminfo_cover_memory() checking early
Message-ID: <20130618010548.GU32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-12-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-12-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 13, 2013 at 09:02:58PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> In order to seperate parsing numa info procedure into two steps,
> we need to set memblock nid later, as it could change memblock
> array, and possible doube memblock.memory array which will need
> to allocate buffer.
> 
> We do not need to use nid in memblock to find out absent pages.

 because...

And please also explain it in the source code with comment including
why the check has to be done early.

> So we can move that numa_meminfo_cover_memory() early.

Maybe "So, we can use the NUMA-unaware absent_pages_in_range() in
numa_meminfo_cover_memory() and call the function before setting nid's
to memblock."

> Also we could change __absent_pages_in_range() to static and use
> absent_pages_in_range() directly.

"As this removes the last user of __absent_pages_in_range(), this
patch also makes the function static."

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
