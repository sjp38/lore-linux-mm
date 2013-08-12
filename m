Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 920D56B0034
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 10:25:55 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id q14so5795191vbe.27
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 07:25:54 -0700 (PDT)
Date: Mon, 12 Aug 2013 10:25:50 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part4 1/4] x86: Make get_ramdisk_{image|size}() global.
Message-ID: <20130812142550.GG15892@htj.dyndns.org>
References: <1375954883-30225-1-git-send-email-tangchen@cn.fujitsu.com>
 <1375954883-30225-2-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375954883-30225-2-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, Aug 08, 2013 at 05:41:20PM +0800, Tang Chen wrote:
> In the following patches, we need to call get_ramdisk_{image|size}()
> to get initrd file's address and size. So make these two functions
> global.
> 
> v1 -> v2:
> As tj suggested, make these two function static inline in
> arch/x86/include/asm/setup.h.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
