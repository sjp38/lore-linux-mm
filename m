Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 79A366B0036
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:59:58 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so2548287pab.3
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:59:58 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so2517988pad.7
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:58:26 -0700 (PDT)
Message-ID: <5240731B.9070906@gmail.com>
Date: Tue, 24 Sep 2013 00:58:03 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 5/5] mem-hotplug: Introduce movablenode boot option
 to control memblock allocation direction.
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com> <1379064655-20874-6-git-send-email-tangchen@cn.fujitsu.com> <20130923155713.GF14547@htj.dyndns.org>
In-Reply-To: <20130923155713.GF14547@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello tejun,

On 09/23/2013 11:57 PM, Tejun Heo wrote:
> Hello,
> 
> On Fri, Sep 13, 2013 at 05:30:55PM +0800, Tang Chen wrote:
>> +#ifdef CONFIG_MOVABLE_NODE
>> +	if (movablenode_enable_srat) {
>> +		/*
>> +		 * When ACPI SRAT is parsed, which is done in initmem_init(),
>> +		 * set memblock back to the default behavior.
>> +		 */
>> +		memblock_set_current_direction(MEMBLOCK_DIRECTION_DEFAULT);
>> +	}
>> +#endif /* CONFIG_MOVABLE_NODE */
> 
> It's kinda weird to have ifdef around the above when all the actual
> code would be compiled and linked regardless of the above ifdef.
> Wouldn't it make more sense to conditionalize
> memblock_direction_bottom_up() so that it's constant false to allow
> the compiler to drop unnecessary code?

you mean we define memblock_set_bottom_up and memblock_bottom_up like below:

#ifdef CONFIG_MOVABLE_NODE
void memblock_set_bottom_up(bool enable)
{
        /* do something */
}

bool memblock_bottom_up()
{
        return  direction == bottom_up;
}
#else
void memblock_set_bottom_up(bool enable)
{
        /* empty */
}

bool memblock_bottom_up()
{
        return false;
}
#endif

right?

thanks.

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
