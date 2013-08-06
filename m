Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id EEB706B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 22:30:47 -0400 (EDT)
Message-ID: <52005F7C.6080004@cn.fujitsu.com>
Date: Tue, 06 Aug 2013 10:29:16 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 RESEND 13/18] x86, numa, mem_hotplug: Skip all the
 regions the kernel resides in.
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com> <1375434877-20704-14-git-send-email-tangchen@cn.fujitsu.com> <51FF44B7.8050704@cn.fujitsu.com> <20130805145212.GA19631@mtj.dyndns.org>
In-Reply-To: <20130805145212.GA19631@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 08/05/2013 10:52 PM, Tejun Heo wrote:
> On Mon, Aug 05, 2013 at 02:22:47PM +0800, Tang Chen wrote:
>> I have resent the v2 patch-set. Would you please give some more
>> comments about the memblock and x86 booting code modification ?
>
> Patch 13 still seems corrupt.  Is it a problem on my side maybe?
> Nope, gmane raw message is corrupt too.
>
>   http://article.gmane.org/gmane.linux.kernel.mm/104549/raw
>
> Can you please verify your mail setup?  It's not very nice to repeat
> the same problem.

Hi tj,

I'm sorry but seeing from lkml, it is OK. And the patch was formatted
by git and sent by git send-email.

   https://lkml.org/lkml/2013/8/2/135

I'll redo and resend this patch again.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
