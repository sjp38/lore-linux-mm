Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7FBA26B0034
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:58:53 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so3431940pdj.7
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:58:53 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so3408008pbc.39
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:46:34 -0700 (PDT)
Message-ID: <52407058.8070806@gmail.com>
Date: Tue, 24 Sep 2013 00:46:16 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/5] x86, mem-hotplug: Support initialize page tables
 from low to high.
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com> <1379064655-20874-5-git-send-email-tangchen@cn.fujitsu.com> <20130923155331.GE14547@htj.dyndns.org>
In-Reply-To: <20130923155331.GE14547@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello tejun,

On 09/23/2013 11:53 PM, Tejun Heo wrote:
> Hey,
> 
> On Fri, Sep 13, 2013 at 05:30:54PM +0800, Tang Chen wrote:
>> init_mem_mapping() is called before SRAT is parsed. And memblock will allocate
>> memory for page tables. To prevent page tables being allocated within hotpluggable
>> memory, we will allocate page tables from the end of kernel image to the higher
>> memory.
> 
> The same comment about patch split as before.  Please make splitting
> out memory_map_from_high() a separate patch.  Also, please choose one
> pair to describe the direction.  The series is currently using four
> variants - top_down/bottom_up, high_to_low/low_to_high,
> from_high/from_low. rev/[none].  Please choose one and stick with it.

OK. will do the split and choose one pair. Thanks for the reminding again.

> 
> Thanks.
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
