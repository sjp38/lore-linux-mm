Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B81556B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 21:58:14 -0400 (EDT)
Received: by mail-yh0-f49.google.com with SMTP id v1so1316114yhn.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:58:13 -0700 (PDT)
Date: Mon, 17 Jun 2013 18:58:06 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 16/22] x86, mm, numa: Move numa emulation
 handling down.
Message-ID: <20130618015806.GY32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-17-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-17-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, Jun 13, 2013 at 09:03:03PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> numa_emulation() needs to allocate buffer for new numa_meminfo
> and distance matrix, so execute it later in x86_numa_init().
> 
> Also we change the behavoir:
> 	- before this patch, if user input wrong data in command
> 	  line, it will fall back to next numa probing or disabling
> 	  numa.
> 	- after this patch, if user input wrong data in command line,
> 	  it will stay with numa info probed from previous probing,
> 	  like ACPI SRAT or amd_numa.
> 
> We need to call numa_check_memblks to reject wrong user inputs early
> so that we can keep the original numa_meminfo not changed.

So, this is another very subtle ordering you're adding without any
comment and I'm not sure it even makes sense because the function can
fail after that point.

I'm getting really doubtful about this whole approach of carefully
splitting discovery and registration.  It's inherently fragile like
hell and the poor documentation makes it a lot worse.  I'm gonna reply
to the head message.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
