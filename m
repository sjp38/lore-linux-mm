From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 05/11] memblock: Introduce allocation order to memblock.
Date: Thu, 5 Sep 2013 17:27:35 +0800
Message-ID: <9474.86240552298$1378373288@news.gmane.org>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
 <1377596268-31552-6-git-send-email-tangchen@cn.fujitsu.com>
 <20130905091615.GB15294@hacker.(null)>
 <52284D12.6050604@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VHVr0-0004wV-7B
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Sep 2013 11:27:54 +0200
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id ACC096B0034
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 05:27:49 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 19:16:15 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 2D2673578050
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 19:27:38 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r859BMrj8978740
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 19:11:22 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r859RaCr006777
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 19:27:37 +1000
Content-Disposition: inline
In-Reply-To: <52284D12.6050604@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Tang,
On Thu, Sep 05, 2013 at 05:21:22PM +0800, Tang Chen wrote:
>Hi Wanpeng,
>
>On 09/05/2013 05:16 PM, Wanpeng Li wrote:
>......
>>>
>>>+/* Allocation order. */
>>
>>How about replace "Allocation order" by "Allocation sequence".
>>
>>The "Allocation order" is ambiguity.
>>
>
>Yes, order is ambiguity. But as tj suggested, I think maybe "direction"
>is better.

Sounds good. ;-)

Regards,
Wanpeng Li 

>
>Thanks. :)
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
