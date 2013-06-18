Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id E3B026B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:57:59 -0400 (EDT)
Received: by mail-bk0-f53.google.com with SMTP id e11so1884250bkh.40
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 09:57:58 -0700 (PDT)
Date: Tue, 18 Jun 2013 18:57:54 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [Part2 PATCH v4 08/15] x86, numa: Save nid when reserve memory
 into memblock.reserved[].
Message-ID: <20130618165753.GB4553@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128619-8987-9-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128619-8987-9-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tang,

On Thu, Jun 13, 2013 at 09:03:32PM +0800, Tang Chen wrote:
> Since we introduced numa_sync_memblock_nid synchronize nid info in
> memblock.reserved[] and numa_meminfo, when numa_meminfo has been
> initialized, we need to save the nid into memblock.reserved[] when
> we reserve memory.

thanks for the updated patches.
I tested linux-next next-20130706 +part1+part2+part3 in a VM, hot-plugging
memory and rebooting with movablecore=acpi. I think with this patch and 9/15
we get the correct nids and the expected behaviour for the "movablecore=acpi"
option.

However, patches 21,22 of part1 and all part3 patches increase kernel usage
of local node memory by putting pagetables local to those nodes. Are these
pagetable pages accounted in part2's memblock_kernel_nodemask? It looks like
part1 and part3 of these patchsets contradict or make the goal of part2 more
difficult to achieve. (I will send more comments for part3 separately).

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
