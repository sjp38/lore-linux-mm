Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3730A6B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:35:42 -0400 (EDT)
Message-ID: <51FB0C95.8040207@cn.fujitsu.com>
Date: Fri, 02 Aug 2013 09:34:13 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 04/18] acpi: Introduce acpi_invalid_table() to check
 if a table is invalid.
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>  <1375340800-19332-5-git-send-email-tangchen@cn.fujitsu.com> <1375396019.10300.32.camel@misato.fc.hp.com>
In-Reply-To: <1375396019.10300.32.camel@misato.fc.hp.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 08/02/2013 06:26 AM, Toshi Kani wrote:
......
>> +int __init acpi_invalid_table(struct cpio_data *file,
>> +			      const char *path, const char *signature)
>
> Since this function verifies a given acpi table in initrd (not that the
> table is invalid), I'd suggest to rename it something like
> acpi_verify_initrd().  Otherwise, it looks good to me.
>

Hi Toshi-san,

Thanks, will change the name.

Thanks.

> Acked-by: Toshi Kani<toshi.kani@hp.com>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
