Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id B9CEF6B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 17:49:28 -0400 (EDT)
Message-ID: <1379108852.13477.14.camel@misato.fc.hp.com>
Subject: Re: [RESEND PATCH v2 3/9] x86, dma: Support allocate memory from
 bottom upwards in dma_contiguous_reserve().
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 13 Sep 2013 15:47:32 -0600
In-Reply-To: <52328839.9010309@cn.fujitsu.com>
References: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>
	  <1378979537-21196-4-git-send-email-tangchen@cn.fujitsu.com>
	 <1379013759.13477.12.camel@misato.fc.hp.com>
	 <52328839.9010309@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, 2013-09-13 at 11:36 +0800, Tang Chen wrote:
> Hi Toshi,
> 
> On 09/13/2013 03:22 AM, Toshi Kani wrote:
> ......
> >> +		if (memblock_direction_bottom_up()) {
> >> +			addr = memblock_alloc_bottom_up(
> >> +						MEMBLOCK_ALLOC_ACCESSIBLE,
> >> +						limit, size, alignment);
> >> +			if (addr)
> >> +				goto success;
> >> +		}
> >
> > I am afraid that this version went to a wrong direction.  Allocating
> > from the bottom up needs to be an internal logic within the memblock
> > allocator.  It should not require the callers to be aware of the
> > direction and make a special request.
> >
> 
> I think my v1 patch-set was trying to do so. Was it too complicated ?
> 
> So just move this logic to memblock_find_in_range_node(), is this OK ?

Yes, the new version looks good on this.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
