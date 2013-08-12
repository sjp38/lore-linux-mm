Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 940876B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 10:17:23 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id cz11so5547744veb.8
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 07:17:22 -0700 (PDT)
Date: Mon, 12 Aug 2013 10:17:18 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part2 2/4] earlycpio.c: Fix the confusing comment of
 find_cpio_data().
Message-ID: <20130812141718.GE15892@htj.dyndns.org>
References: <1375938239-18769-1-git-send-email-tangchen@cn.fujitsu.com>
 <1375938239-18769-3-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375938239-18769-3-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, Aug 08, 2013 at 01:03:57PM +0800, Tang Chen wrote:
> The comments of find_cpio_data() says:
> 
>   * @offset: When a matching file is found, this is the offset to the
>   *          beginning of the cpio. ......
> 
> But according to the code,
> 
>   dptr = PTR_ALIGN(p + ch[C_NAMESIZE], 4);
>   nptr = PTR_ALIGN(dptr + ch[C_FILESIZE], 4);
>   ....
>   *offset = (long)nptr - (long)data;	/* data is the cpio file */
> 
> @offset is the offset of the next file, not the matching file itself.
> This is confused and may cause unnecessary waste of time to debug.
> So fix it.
> 
> v1 -> v2:
> As tj suggested, rename @offset to @nextoff which is more clear to
> users. And also adjust the new comments.
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
