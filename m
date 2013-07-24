Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E39F66B0038
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:13:50 -0400 (EDT)
Message-ID: <51EFA97F.2090701@cn.fujitsu.com>
Date: Wed, 24 Jul 2013 18:16:31 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/21] x86, acpi: Try to find SRAT in firmware earlier.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com> <51EF1143.1020503@linux.vnet.ibm.com>
In-Reply-To: <51EF1143.1020503@linux.vnet.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 07:26 AM, Cody P Schafer wrote:
> On 07/19/2013 12:59 AM, Tang Chen wrote:
......
>> +/*
>> + * acpi_get_table_desc - Get the acpi table descriptor of a specific
>> table.
>> + * @signature: The signature of the table to be found.
>> + * @out_desc: The out returned descriptor.
>
> The "@out_desc:" line looks funky. Also, I believe changes to this file
> need to go in via acpica & probably conform to their commenting standards?
>

OK, followed.

......
>
> Perhaps: "Iterate over acpi_gbl_root_table_list to find SRAT then return
> its phys addr"
>
> Though I wonder if this comment is even needed, as the iteration is done
> in acpi_get_table_desc() (added above).
>

OK, will remove the comment.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
