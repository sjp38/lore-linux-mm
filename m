Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id B98636B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 19:33:25 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 17 Aug 2012 17:33:24 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A9A5119D803D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 17:33:22 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7HNXMa4178510
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 17:33:22 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7HNXL7p026547
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 17:33:22 -0600
Message-ID: <502ED4C0.70305@linux.vnet.ibm.com>
Date: Fri, 17 Aug 2012 18:33:20 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com> <5021795A.5000509@linux.vnet.ibm.com> <5024067F.3010602@linux.vnet.ibm.com> <2e9ccb4f-1339-4c26-88dd-ea294b022127@default> <50254F69.2000409@linux.vnet.ibm.com> <8fa37327-17ff-4734-9007-40412b18d0fb@default>
In-Reply-To: <8fa37327-17ff-4734-9007-40412b18d0fb@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

On 08/17/2012 05:21 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCH 0/4] promote zcache from staging
>>
>> On 08/09/2012 03:20 PM, Dan Magenheimer wrote
>>> I also wonder if you have anything else unusual in your
>>> test setup, such as a fast swap disk (mine is a partition
>>> on the same rotating disk as source and target of the kernel build,
>>> the default install for a RHEL6 system)?
>>
>> I'm using a normal SATA HDD with two partitions, one for
>> swap and the other an ext3 filesystem with the kernel source.
>>
>>> Or have you disabled cleancache?
>>
>> Yes, I _did_ disable cleancache.  I could see where having
>> cleancache enabled could explain the difference in results.
> 
> Sorry to beat a dead horse, but I meant to report this
> earlier in the week and got tied up by other things.
> 
> I finally got my test scaffold set up earlier this week
> to try to reproduce my "bad" numbers with the RHEL6-ish
> config file.
> 
> I found that with "make -j28" and "make -j32" I experienced
> __DATA CORRUPTION__.  This was repeatable.

I actually hit this for the first time a few hours ago when
I was running performance for your rewrite.  I didn't know
what to make of it yet.  The 24-thread kernel build failed
when both frontswap and cleancache were enabled.

> The type of error led me to believe that the problem was
> due to concurrency of cleancache reclaim.  I did not try
> with cleancache disabled to prove/support this theory
> but it is consistent with the fact that you (Seth) have not
> seen a similar problem and has disabled cleancache.
> 
> While this problem is most likely in my code and I am
> suitably chagrined, it re-emphasizes the fact that
> the current zcache in staging is 20-month old "demo"
> code.  The proposed new zcache codebase handles concurrency
> much more effectively.

I imagine this can be solved without rewriting the entire
codebase.  If your new code contains a fix for this, can we
just pull it as a single patch?

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
