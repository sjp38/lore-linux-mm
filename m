Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 26EE16B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 21:43:57 -0400 (EDT)
Message-ID: <51EF31FA.3030602@cn.fujitsu.com>
Date: Wed, 24 Jul 2013 09:46:34 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/21] acpi: Print Hot-Pluggable Field in SRAT.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-2-git-send-email-tangchen@cn.fujitsu.com> <20130723184843.GG21100@mtj.dyndns.org>
In-Reply-To: <20130723184843.GG21100@mtj.dyndns.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, joJoee@perches.com
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 02:48 AM, Tejun Heo wrote:
> On Fri, Jul 19, 2013 at 03:59:14PM +0800, Tang Chen wrote:
>> The Hot-Pluggable field in SRAT suggests if the memory could be
>> hotplugged while the system is running. Print it as well when
>> parsing SRAT will help users to know which memory is hotpluggable.
>>
>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>> Reviewed-by: Wanpeng Li<liwanp@linux.vnet.ibm.com>
>
> Acked-by: Tejun Heo<tj@kernel.org>
>
> But a nit below
>
>> +	pr=5Finfo("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
>> +		node, pxm,
>> +		(unsigned long long) start, (unsigned long long) end - 1,
>> +		hotpluggable ? "Hot Pluggable" : "");
>
> The following would be more conventional.
>
>    "...10Lx]%s\n", ..., hotpluggable ? " Hot Pluggable" : ""
>
> Also, isn't "Hot Pluggable" a bit too verbose?  "hotplug" should be
> fine, I think.
>

Hi tj, Joe,

OK=EF=BC=8Cwill change it as you guys said.
Thank you very much.

Thanks.

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
