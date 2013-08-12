Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 2F3C96B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 04:55:02 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so6561842pbc.35
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 01:55:01 -0700 (PDT)
Message-ID: <5208A2D7.7090102@gmail.com>
Date: Mon, 12 Aug 2013 16:54:47 +0800
From: Tang Chen <imtangchen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130809163220.GU20515@mtj.dyndns.org>
In-Reply-To: <20130809163220.GU20515@mtj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 08/10/2013 12:32 AM, Tejun Heo wrote:
> Hello,
>
> On Thu, Aug 08, 2013 at 06:16:12PM +0800, Tang Chen wrote:
>> In previous parts' patches, we have obtained SRAT earlier enough, right after
>> memblock is ready. So this patch-set does the following things:
> Can you please set up a git branch with all patches?
>
> Thanks.

Please refer to :

https://github.com/imtangchen/linux movablenode-boot-option

It contains all 5 parts patches.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
