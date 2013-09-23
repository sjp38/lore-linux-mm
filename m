Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 24D366B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:04:08 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so2487980pab.10
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:04:07 -0700 (PDT)
Received: by mail-ye0-f181.google.com with SMTP id r14so1204437yen.40
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:53:35 -0700 (PDT)
Date: Mon, 23 Sep 2013 11:53:31 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 4/5] x86, mem-hotplug: Support initialize page tables
 from low to high.
Message-ID: <20130923155331.GE14547@htj.dyndns.org>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
 <1379064655-20874-5-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379064655-20874-5-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hey,

On Fri, Sep 13, 2013 at 05:30:54PM +0800, Tang Chen wrote:
> init_mem_mapping() is called before SRAT is parsed. And memblock will allocate
> memory for page tables. To prevent page tables being allocated within hotpluggable
> memory, we will allocate page tables from the end of kernel image to the higher
> memory.

The same comment about patch split as before.  Please make splitting
out memory_map_from_high() a separate patch.  Also, please choose one
pair to describe the direction.  The series is currently using four
variants - top_down/bottom_up, high_to_low/low_to_high,
from_high/from_low. rev/[none].  Please choose one and stick with it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
