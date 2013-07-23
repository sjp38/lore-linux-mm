Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 953E46B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 17:01:00 -0400 (EDT)
Received: by mail-ye0-f176.google.com with SMTP id m14so2618096yen.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 14:00:59 -0700 (PDT)
Date: Tue, 23 Jul 2013 17:00:53 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 16/21] x86, memblock, mem-hotplug: Free hotpluggable
 memory reserved by memblock.
Message-ID: <20130723210053.GU21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-17-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-17-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 19, 2013 at 03:59:29PM +0800, Tang Chen wrote:
> We reserved hotpluggable memory in memblock at early time. And when memory
> initialization is done, we have to free it to buddy system.
> 
> This patch free memory reserved by memblock with flag MEMBLK_HOTPLUGGABLE.

Sequencing patches this way means machines will run with hotpluggable
regions reserved inbetween.  Please put the reserving and freeing into
the same patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
