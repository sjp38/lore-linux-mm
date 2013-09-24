Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 581BE6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 22:47:01 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so8103761iec.30
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 19:47:01 -0700 (PDT)
Received: by mail-qa0-f51.google.com with SMTP id j15so2109576qaq.3
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 19:46:58 -0700 (PDT)
Date: Mon, 23 Sep 2013 22:46:54 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/5] memblock: Improve memblock to support allocation
 from lower address.
Message-ID: <20130924024654.GE3482@htj.dyndns.org>
References: <1379064655-20874-1-git-send-email-tangchen@cn.fujitsu.com>
 <1379064655-20874-3-git-send-email-tangchen@cn.fujitsu.com>
 <20130923155027.GD14547@htj.dyndns.org>
 <52408351.8080400@gmail.com>
 <20130923202147.GB28667@mtj.dyndns.org>
 <5240FBEF.10102@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5240FBEF.10102@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, toshi.kani@hp.com, liwanp@linux.vnet.ibm.com, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Tue, Sep 24, 2013 at 10:41:51AM +0800, Zhang Yanfei wrote:
> I see. But I think memblock_set_alloc_above_kernel may lose the info
> that we are doing bottom-up allocation. So my idea is we introduce
> pure bottom-up allocation mode in previous patches and we use the
> bottom-up allocation here and limit the start address above the kernel
> , with explicit comments to indicate this.

It probably doesn't matter either way.  I was just a bit bothered that
it's called bottom-up when it implies more including the retry logic.
Its use of bottom-up allocation is really an implementation logic to
achieve the goal of allocating memory above kernel image after all,
but yeah minor point either way.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
