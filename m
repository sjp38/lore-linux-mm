Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 814246B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:02:35 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id f73so3057903yha.41
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 13:02:34 -0700 (PDT)
Date: Tue, 23 Jul 2013 16:02:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 10/21] earlycpio.c: Fix the confusing comment of
 find_cpio_data().
Message-ID: <20130723200227.GO21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-11-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-11-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 19, 2013 at 03:59:23PM +0800, Tang Chen wrote:
> - * @offset: When a matching file is found, this is the offset to the
> - *          beginning of the cpio. It can be used to iterate through
> - *          the cpio to find all files inside of a directory path
> + * @offset: When a matching file is found, this is the offset from the
> + *          beginning of the cpio to the beginning of the next file, not the
> + *          matching file itself. It can be used to iterate through the cpio
> + *          to find all files inside of a directory path

Nicely spotted.  I think we can go further and rename it to @nextoff.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
