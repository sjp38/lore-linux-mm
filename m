Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id k9VAlVOH149696
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 21:47:31 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9VAeV5c227430
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 21:40:36 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9VAb5I1002469
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 21:37:05 +1100
Message-ID: <45472736.8030701@in.ibm.com>
Date: Tue, 31 Oct 2006 16:06:38 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] RFC: Memory Controller
References: <20061030103356.GA16833@in.ibm.com>	<4545D51A.1060808@in.ibm.com>	<4546212B.4010603@openvz.org>	<454638D2.7050306@in.ibm.com>	<45463F70.1010303@in.ibm.com>	<45470FEE.6040605@openvz.org>	<45471510.4070407@in.ibm.com> <20061031014243.1153655b.akpm@osdl.org>
In-Reply-To: <20061031014243.1153655b.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Pavel Emelianov <xemul@openvz.org>, vatsa@in.ibm.com, dev@openvz.org, sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, pj@sgi.com, matthltc@us.ibm.com, dipankar@in.ibm.com, rohitseth@google.com, menage@google.com, linux-mm@kvack.org, Vaidyanathan S <svaidy@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 31 Oct 2006 14:49:12 +0530
> Balbir Singh <balbir@in.ibm.com> wrote:
> 
>> The idea behind limiting the page cache is this
>>
>> 1. Lets say one container fills up the page cache.
>> 2. The other containers will not be able to allocate memory (even
>> though they are within their limits) without the overhead of having
>> to flush the page cache and freeing up occupied cache. The kernel
>> will have to pageout() the dirty pages in the page cache.
> 
> There's a vast difference between clean pagecache and dirty pagecache in this
> context.  It is terribly imprecise to use the term "pagecache".  And it would be
> a poor implementation which failed to distinguish between clean pagecache and
> dirty pagecache.
> 

Yes, I agree, it will be a good idea to distinguish between the two.

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
