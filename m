Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 1AB466B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:18:06 -0400 (EDT)
Message-ID: <51EF4806.7070805@cn.fujitsu.com>
Date: Wed, 24 Jul 2013 11:20:38 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/21] earlycpio.c: Fix the confusing comment of find_cpio_data().
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-11-git-send-email-tangchen@cn.fujitsu.com> <20130723200227.GO21100@mtj.dyndns.org>
In-Reply-To: <20130723200227.GO21100@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 04:02 AM, Tejun Heo wrote:
> On Fri, Jul 19, 2013 at 03:59:23PM +0800, Tang Chen wrote:
>> - * @offset: When a matching file is found, this is the offset to the
>> - *          beginning of the cpio. It can be used to iterate through
>> - *          the cpio to find all files inside of a directory path
>> + * @offset: When a matching file is found, this is the offset from the
>> + *          beginning of the cpio to the beginning of the next file, not the
>> + *          matching file itself. It can be used to iterate through the cpio
>> + *          to find all files inside of a directory path
>
> Nicely spotted.  I think we can go further and rename it to @nextoff.

OK, followed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
