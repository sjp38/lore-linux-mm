Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A465A6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:34:30 -0400 (EDT)
Message-ID: <51FB0C49.3090603@cn.fujitsu.com>
Date: Fri, 02 Aug 2013 09:32:57 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 03/18] acpi: Remove "continue" in macro INVALID_TABLE().
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>  <1375340800-19332-4-git-send-email-tangchen@cn.fujitsu.com> <1375394806.10300.24.camel@misato.fc.hp.com>
In-Reply-To: <1375394806.10300.24.camel@misato.fc.hp.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 08/02/2013 06:06 AM, Toshi Kani wrote:
......
>>   /* Non-fatal errors: Affected tables/files are ignored */
>>   #define INVALID_TABLE(x, path, name)					\
>
> Since you are touching this macro, I'd suggest to rename it something
> like ACPI_INVALID_TABLE().  INVALID_TABLE() sounds too generic to me.
> Otherwise, it looks good.

Hi Toshi-san,

Thanks for your advice and ack, will change the name.

Thanks.

>
> Acked-by: Toshi Kani<toshi.kani@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
