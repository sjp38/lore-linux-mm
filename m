Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 94BEB6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 09:08:35 -0400 (EDT)
Message-ID: <51FFA393.2080301@zytor.com>
Date: Mon, 05 Aug 2013 06:07:31 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/18] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 08/01/2013 12:06 AM, Tang Chen wrote:
> This patch-set aims to solve some problems at system boot time
> to enhance memory hotplug functionality.
> 
> [Background]
> 
> The Linux kernel cannot migrate pages used by the kernel because
> of the kernel direct mapping. Since va = pa + PAGE_OFFSET, if the
> physical address is changed, we cannot simply update the kernel
> pagetable. On the contrary, we have to update all the pointers
> pointing to the virtual address, which is very difficult to do.
> 

It does beg the question if that "since" statement should be changed ...
we already have it handled differently on Xen PV, but that is kind of
"special".  There are a whole bunch of other issues with moving kernel
memory around: you have to worry what might have a physical address
cached somewhere and what might be in active use and so on... I am not
really suggesting it as anything but food for thought at this time.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
