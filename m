Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 2408C6B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 08:04:37 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 9 Sep 2013 17:27:39 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 5ABFF394005A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 17:34:20 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r89C4SfV34078968
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 17:34:29 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r89C4U11030844
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 17:34:30 +0530
Date: Mon, 9 Sep 2013 20:04:29 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
Message-ID: <20130909120429.GA25626@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130904192215.GG26609@mtj.dyndns.org>
 <52299935.0302450a.26c9.ffffb240SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130906151526.GA22423@mtj.dyndns.org>
 <157310e1-f8cb-4184-b58d-63cf9fa611ee@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <157310e1-f8cb-4184-b58d-63cf9fa611ee@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Peter and Tejun,
On Fri, Sep 06, 2013 at 08:47:45AM -0700, H. Peter Anvin wrote:
>Specifically there are a bunch of things which need to be below a certain address (which one varies.)
>

off-topic 

If memblock allocator have less fragmentation than old bootmem allocator?

Regards,
Wanpeng Li 

>Tejun Heo <tj@kernel.org> wrote:
>>Hello, Wanpeng.
>>
>>On Fri, Sep 06, 2013 at 04:58:11PM +0800, Wanpeng Li wrote:
>>> What's the root reason memblock alloc from high to low? To reduce 
>>> fragmentation or ...
>>
>>Because low memory tends to be more precious, it's just easier to pack
>>everything towards the top so that we don't have to worry about which
>>zone to use for allocation and fallback logic.
>>
>>Thanks.
>
>-- 
>Sent from my mobile phone.  Please pardon brevity and lack of formatting.
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
