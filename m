Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E3D6F6B009D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 05:02:40 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id n8L92Z2i015483
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:32:35 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8L92ZkJ1917014
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:32:35 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8L92Yej002841
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:32:35 +0530
Message-ID: <4AB74129.90402@in.ibm.com>
Date: Mon, 21 Sep 2009 14:32:33 +0530
From: Sachin Sant <sachinp@in.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-2-git-send-email-mel@csn.ul.ie> <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com> <4AB5FD4D.3070005@kernel.org> <4AB5FFF8.7000602@cs.helsinki.fi> <4AB6508C.4070602@kernel.org> <4AB739A6.5060807@in.ibm.com> <20090921084248.GC12726@csn.ul.ie>
In-Reply-To: <20090921084248.GC12726@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
>> I applied the three patches from Mel and one from Tejun.
>>     
>
> Thanks Sachin
>
> Was there any useful result from Tejun's patch applied on its own?
>   
Haven't tried with just the patch from Tejun. I will give this a try.
I might not get a chance to test this until late in the evening my time.
(Today being a holiday for me )

>> Tejun, the above hang looks exactly the same as the one
>> i have reported here :
>>
>> http://lists.ozlabs.org/pipermail/linuxppc-dev/2009-September/075791.html
>>
>> This particular hang was bisected to the following patch
>>
>> powerpc64: convert to dynamic percpu allocator
>>
>> This hang can be recreated without SLQB. So i think this is a different
>> problem. 
>>
>>     
>
> Was that bug ever resolved?
>   
The bug was still present with git9(78f28b..). With latest git
git10(ebc79c4 ..)i haven't tested it yet because of perf counter
build errors.

Thanks
-Sachin


-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
