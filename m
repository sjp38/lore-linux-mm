Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8I4xO7J001322
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 10:29:24 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8I4wh311237024
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 10:29:23 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8I4whLI017759
	for <linux-mm@kvack.org>; Thu, 18 Sep 2008 14:58:43 +1000
Message-ID: <48D1DFE0.5010208@linux.vnet.ibm.com>
Date: Wed, 17 Sep 2008 21:58:08 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page (v3)
References: <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com> <20080910012048.GA32752@balbir.in.ibm.com> <1221085260.6781.69.camel@nimitz> <48C84C0A.30902@linux.vnet.ibm.com> <1221087408.6781.73.camel@nimitz> <20080911103500.d22d0ea1.kamezawa.hiroyu@jp.fujitsu.com> <48C878AD.4040404@linux.vnet.ibm.com> <20080911105638.1581db90.kamezawa.hiroyu@jp.fujitsu.com> <20080917232826.GA19256@balbir.in.ibm.com> <20080917184008.92b7fc4c.akpm@linux-foundation.org> <20080918134304.93985542.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080918134304.93985542.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 17 Sep 2008 18:40:08 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>>> Advantages of the patch
>>>
>>> 1. It removes the extra pointer in struct page
>>>
>>> Disadvantages
>>>
>>> 1. Radix tree lookup is not an O(1) operation, once the page is known
>>>    getting to the page_cgroup (pc) is a little more expensive now.
>> Why are we doing this?  I can guess, but I'd rather not have to.
>>
>> a) It's slower.
>>
>> b) It uses even more memory worst-case.
>>
>> c) It uses less memory best-case.
>>
>> someone somewhere decided that (Aa + Bb) / Cc < 1.0.  What are the values
>> of A, B and C and where did they come from? ;)
>>
> 
> Balbir, don't you like pre-allocate-page-cgroup-at-boot at all ?
> I don't like radix-tree for objects which can spread to very vast/sparse area ;)
> 

I tried one version, but before trying a pre-allocation version, I wanted to
spread out the radix-tree and try and the results seemed quite impressive. We
can still do pre-allocation, but it gets more complicated as we start supporting
all memory models. I do have a design on paper, but it is much more complex than
this.

> BTW, I already have lazy-lru-by-pagevec protocol on my patch(hash version) and
> seems to work well. I'm now testing it and will post today if I'm enough lucky.

cool! Please do post what numbers you see as well. I would appreciate if you can
try this version and see what sort of performance issues you see.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
