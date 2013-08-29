Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 183176B0032
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 21:37:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 29 Aug 2013 11:25:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9A1A72CE8055
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 11:37:05 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7T1andu33423468
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 11:36:54 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7T1axRv030470
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 11:37:00 +1000
Date: Thu, 29 Aug 2013 09:36:57 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
Message-ID: <20130829013657.GA22599@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130828151909.GE9295@htj.dyndns.org>
 <521EA44E.1020205@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <521EA44E.1020205@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Tang,
On Thu, Aug 29, 2013 at 09:30:54AM +0800, Tang Chen wrote:
>On 08/28/2013 11:19 PM, Tejun Heo wrote:
>......
>>Doesn't apply to -master, -next or tip.  Again, can you please include
>>which tree and git commit the patches are against in the patch
>>description?  How is one supposed to know on top of which tree you're
>>working?  It is in your benefit to make things easier for the prosepct
>>reviewers.  Trying to guess and apply the patches to different devel
>>branches and failing isn't productive and frustates your prospect
>>reviewers who would of course have negative pre-perception going into
>>the review and this isn't the first time this issue was raised either.
>>
>
>Hi tj,
>
>Sorry for the trouble. Please refer to the following branch:
>
>https://github.com/imtangchen/linux.git  movablenode-boot-option
>

Could you post your testcase? So I can test it on x86 and powerpc machines.

Regards,
Wanpeng Li 

>Thanks.
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
