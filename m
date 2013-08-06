Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 74B446B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 11:11:07 -0400 (EDT)
Received: by mail-qe0-f52.google.com with SMTP id cz11so279009qeb.39
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 08:11:06 -0700 (PDT)
Date: Tue, 6 Aug 2013 11:10:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 RESEND 13/18] x86, numa, mem_hotplug: Skip all the
 regions the kernel resides in.
Message-ID: <20130806151058.GA10779@mtj.dyndns.org>
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com>
 <1375434877-20704-14-git-send-email-tangchen@cn.fujitsu.com>
 <51FF44B7.8050704@cn.fujitsu.com>
 <20130805145212.GA19631@mtj.dyndns.org>
 <52005F7C.6080004@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52005F7C.6080004@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Tue, Aug 06, 2013 at 10:29:16AM +0800, Tang Chen wrote:
> I'm sorry but seeing from lkml, it is OK. And the patch was formatted
> by git and sent by git send-email.
> 
>   https://lkml.org/lkml/2013/8/2/135

Yeah, I checked that too but I think lkml.org is doing the QP
decoding.  The raw link from gmane shows the raw message received so
I'm relatively sure that something on the sending side is doing QP
encoding as the mail travels out.  Can you please try sending it via
gmail?  gmail does smtp and you can set the sender address to whatever
you want too as long as you can receive messages on that address.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
