Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id F2F3C6B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 05:02:35 -0400 (EDT)
Message-ID: <52284860.60407@cn.fujitsu.com>
Date: Thu, 05 Sep 2013 17:01:20 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com> <20130904192215.GG26609@mtj.dyndns.org>
In-Reply-To: <20130904192215.GG26609@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi tj,

On 09/05/2013 03:22 AM, Tejun Heo wrote:
......
> I'm expectedly happier with this approach but some overall review
> points.
>
> * I think patch splitting went a bit too far.  e.g. it doesn't make
>    much sense or helps anything to split "introduction of a param" from
>    "the param doing something".
>
> * I think it's a lot more complex than necessary.  Just implement a
>    single function - memblock_alloc_bottom_up(@start) where specifying
>    MEMBLOCK_ALLOC_ANYWHERE restores top down behavior and do
>    memblock_alloc_bottom_up(end_of_kernel) early during boot.  If the
>    bottom up mode is set, just try allocating bottom up from the
>    specified address and if that fails do normal top down allocation.
>    No need to meddle with the callers.  The only change necessary
>    (well, aside from the reordering) outside memblock is adding two
>    calls to the above function.
>
> * I don't think "order" is the right word here.  "direction" probably
>    fits a lot better.
>

Thanks for the advices. I'll try to simply the code and send a new 
patch-set soon.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
