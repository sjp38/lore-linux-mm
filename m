Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 98E766B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 20:53:19 -0400 (EDT)
Received: by mail-ye0-f172.google.com with SMTP id l13so1167928yen.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:53:18 -0700 (PDT)
Date: Mon, 17 Jun 2013 17:53:11 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 10/22] x86, mm, numa: Move two functions calling
 on successful path later
Message-ID: <20130618005311.GT32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-11-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-11-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

Does the subject match the patch content?  What two functions?  The
patch is separating out the actual registration part so that the
discovery part can happen earlier, right?

> Currently, parsing numa info needs to allocate some buffer and need to be
> called after init_mem_mapping. So try to split parsing numa info procedure
> into two steps:
> 	- The first step will be called before init_mem_mapping, and it
> 	  should not need allocate buffers.

Document the requirement somewhere in the source code?

> 	- The second step will cantain all the buffer related code and be
> 	  executed later.
> 
> At last we will have early_initmem_init() and initmem_init().

Do you mean "eventually" or "in the end" by "at last"?

> This patch implements only the first step.
> 
> setup_node_data() and numa_init_array() are only called for successful
> path, so we can move these two callings to x86_numa_init(). That will also
> make numa_init() smaller and more readable.

I find the description somewhat difficult to follow.  :(

> -v2: remove online_node_map clear in numa_init(), as it is only
>      set in setup_node_data() at last in successful path.

I don't get this.  What prevents specific numa init functions (numaq,
x86_acpi, amd...) from updating node_online_map?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
