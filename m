Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 8EA3E6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 18:10:09 -0400 (EDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 23 Aug 2012 16:10:08 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 408F4C40004
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:10:06 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NMA3iM162608
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:10:04 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NMA2sF004709
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:10:03 -0600
Message-ID: <5036AA38.6010400@linux.vnet.ibm.com>
Date: Thu, 23 Aug 2012 17:10:00 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] revert changes to zcache_do_preload()
References: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120823205648.GA2066@barrios>
In-Reply-To: <20120823205648.GA2066@barrios>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, xiaoguangrong@linux.vnet.ibm.com

On 08/23/2012 03:56 PM, Minchan Kim wrote:
> Hi Seth,
> 
> On Thu, Aug 23, 2012 at 10:33:09AM -0500, Seth Jennings wrote:
>> This patchset fixes a regression in 3.6 by reverting two dependent
>> commits that made changes to zcache_do_preload().
>>
>> The commits undermine an assumption made by tmem_put() in
>> the cleancache path that preemption is disabled.  This change
>> introduces a race condition that can result in the wrong page
>> being returned by tmem_get(), causing assorted errors (segfaults,
>> apparent file corruption, etc) in userspace.
>>
>> The corruption was discussed in this thread:
>> https://lkml.org/lkml/2012/8/17/494
> 
> I think changelog isn't enough to explain what's the race.
> Could you write it down in detail?

I didn't come upon this solution via code inspection, but
rather through discovering that the issue didn't exist in
v3.5 and just looking at the changes since then.

> And you should Cc'ed Xiao who is author of reverted patch.

Thanks for adding Xiao.  I meant to do this. For some reason
I thought that you submitted that patchset :-/
My bad.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
