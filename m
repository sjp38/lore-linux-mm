Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id AC4466B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 01:05:47 -0400 (EDT)
Message-ID: <51BAA557.7060501@cn.fujitsu.com>
Date: Fri, 14 Jun 2013 13:08:39 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part1 PATCH v5 21/22] x86, mm: Make init_mem_mapping be able
 to be called several times
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <1371128589-8953-22-git-send-email-tangchen@cn.fujitsu.com> <aad34de7-8ff7-442d-ad8a-bed2a6e3edea@email.android.com> <CAE9FiQXjg1zZB8veUHH2u9T5G1X8VMdMyY528YDhJtsFjKPxPQ@mail.gmail.com>
In-Reply-To: <CAE9FiQXjg1zZB8veUHH2u9T5G1X8VMdMyY528YDhJtsFjKPxPQ@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>

On 06/14/2013 06:47 AM, Yinghai Lu wrote:
> On Thu, Jun 13, 2013 at 11:35 AM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com>  wrote:
>> Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>>
>>> From: Yinghai Lu<yinghai@kernel.org>
>>>
>>> Prepare to put page table on local nodes.
>>>
>>> Move calling of init_mem_mapping() to early_initmem_init().
>>>
>>> Rework alloc_low_pages to allocate page table in following order:
>>>        BRK, local node, low range
>>>
>>> Still only load_cr3 one time, otherwise we would break xen 64bit again.
>>>
>>
>>
>>
>> Sigh..  Can that comment on Xen be removed please.  The issue was fixed last release  and I believe I already asked to remove that comment as it is not true anymore.
>
> Sorry about that again, I thought I removed that already.

Sorry I didn't notice that. Will remove it if Yinghai or I resend this 
patch-set.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
