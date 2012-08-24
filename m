Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A90D16B005D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 22:21:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Fri, 24 Aug 2012 07:51:14 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7O2LA744653446
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 07:51:10 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7O2LARo032181
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:21:10 +1000
Message-ID: <5036E514.1090509@linux.vnet.ibm.com>
Date: Fri, 24 Aug 2012 10:21:08 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] revert changes to zcache_do_preload()
References: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120823205648.GA2066@barrios> <5036AA38.6010400@linux.vnet.ibm.com> <20120823232845.GE5369@bbox>
In-Reply-To: <20120823232845.GE5369@bbox>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 08/24/2012 07:28 AM, Minchan Kim wrote:
> On Thu, Aug 23, 2012 at 05:10:00PM -0500, Seth Jennings wrote:
>> On 08/23/2012 03:56 PM, Minchan Kim wrote:
>>> Hi Seth,
>>>
>>> On Thu, Aug 23, 2012 at 10:33:09AM -0500, Seth Jennings wrote:
>>>> This patchset fixes a regression in 3.6 by reverting two dependent
>>>> commits that made changes to zcache_do_preload().
>>>>
>>>> The commits undermine an assumption made by tmem_put() in
>>>> the cleancache path that preemption is disabled.  This change
>>>> introduces a race condition that can result in the wrong page
>>>> being returned by tmem_get(), causing assorted errors (segfaults,
>>>> apparent file corruption, etc) in userspace.
>>>>
>>>> The corruption was discussed in this thread:
>>>> https://lkml.org/lkml/2012/8/17/494
>>>
>>> I think changelog isn't enough to explain what's the race.
>>> Could you write it down in detail?
>>
>> I didn't come upon this solution via code inspection, but
>> rather through discovering that the issue didn't exist in
>> v3.5 and just looking at the changes since then.
> 
> Okay, then, why do you think the patchsets are culprit?
> I didn't look the cleanup patch series of Xiao at that time
> so I can be wrong but as I just look through patch of
> "zcache: optimize zcache_do_preload", I can't find any fault
> because zcache_put_page checks irq_disable so we don't need
> to disable preemption so it seems that patch is correct to me.
> If the race happens by preemption, BUG_ON in zcache_put_page
> should catch it.

Confused me too!

And the first patch just do the cleanup, it is not different
before the patch and after the patch, what i missed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
