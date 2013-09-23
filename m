Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id ECB4D6B0037
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 12:08:36 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3374215pbb.5
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:08:36 -0700 (PDT)
Received: by mail-ve0-f180.google.com with SMTP id jz11so2498030veb.11
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:57:18 -0700 (PDT)
Date: Mon, 23 Sep 2013 11:57:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 5/5] mem-hotplug: Introduce movablenode boot option to
 control memblock allocation direction.
Message-ID: <20130923155713.GF14547@htj.dyndns.org>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
 <1379064655-20874-6-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379064655-20874-6-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Fri, Sep 13, 2013 at 05:30:55PM +0800, Tang Chen wrote:
> +#ifdef CONFIG_MOVABLE_NODE
> +	if (movablenode_enable_srat) {
> +		/*
> +		 * When ACPI SRAT is parsed, which is done in initmem_init(),
> +		 * set memblock back to the default behavior.
> +		 */
> +		memblock_set_current_direction(MEMBLOCK_DIRECTION_DEFAULT);
> +	}
> +#endif /* CONFIG_MOVABLE_NODE */

It's kinda weird to have ifdef around the above when all the actual
code would be compiled and linked regardless of the above ifdef.
Wouldn't it make more sense to conditionalize
memblock_direction_bottom_up() so that it's constant false to allow
the compiler to drop unnecessary code?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
