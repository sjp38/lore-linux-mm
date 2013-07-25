Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id BF8286B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 02:40:34 -0400 (EDT)
Message-ID: <51F0C8ED.3070200@cn.fujitsu.com>
Date: Thu, 25 Jul 2013 14:42:53 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/21] memblock, numa: Introduce flag into memblock.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-3-git-send-email-tangchen@cn.fujitsu.com> <20130723190928.GH21100@mtj.dyndns.org> <51EF4196.8050303@cn.fujitsu.com> <20130724155458.GA20377@mtj.dyndns.org>
In-Reply-To: <20130724155458.GA20377@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 11:54 PM, Tejun Heo wrote:
> On Wed, Jul 24, 2013 at 10:53:10AM +0800, Tang Chen wrote:
>>> Let's please drop "with" and do we really need to print full 16
>>> digits?
>>
>> Sure, will remove "with". But I think printing out the full flags is batter.
>> The output seems more tidy.
>
> I mean, padding is fine but you can just print out 4 or even 2 digits
> and will be fine for the foreseeable future.

OK. In this patch-set, there won't more than two flags. I think one 
hexadecimal
number is enough. I'll print two digits for the foreseeable future.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
