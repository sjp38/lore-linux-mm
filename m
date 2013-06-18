Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E483D6B0034
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 21:08:24 -0400 (EDT)
Received: by mail-ye0-f181.google.com with SMTP id g12so1151225yee.26
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:08:24 -0700 (PDT)
Date: Mon, 17 Jun 2013 18:08:16 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 12/22] x86, mm, numa: Move
 node_map_pfn_alignment() to x86
Message-ID: <20130618010816.GV32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-13-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-13-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 13, 2013 at 09:02:59PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> Move node_map_pfn_alignment() to arch/x86/mm as there is no
> other user for it.
> 
> Will update it to use numa_meminfo instead of memblock.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> Tested-by: Tang Chen <tangchen@cn.fujitsu.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
