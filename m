Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 653B56B0032
	for <linux-mm@kvack.org>; Sun,  2 Jun 2013 21:56:35 -0400 (EDT)
Message-ID: <51ABF873.8090409@cn.fujitsu.com>
Date: Mon, 03 Jun 2013 09:59:15 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/13] memblock, numa: Introduce flag into memblock.
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com> <1369387762-17865-7-git-send-email-tangchen@cn.fujitsu.com> <20130603013034.GA31743@hacker.(null)>
In-Reply-To: <20130603013034.GA31743@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Li,

On 06/03/2013 09:30 AM, Wanpeng Li wrote:
> On Fri, May 24, 2013 at 05:29:15PM +0800, Tang Chen wrote:
>> There is no flag in memblock to discribe what type the memory is.
>
> s/discribe/describe

OK.
......
>>
>> +#define MEMBLK_FLAGS_DEFAULT	0
>> +
>
> MEMBLK_FLAGS_DEFAULT is one of the memblock flags, it should also include in
> memblock_flags emum.
>

Hum, here I think I can change all the flags in the enum into macro. 
Seems that
the macro is easier to use.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
