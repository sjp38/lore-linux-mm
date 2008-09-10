Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8AFWMn7004059
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 21:02:22 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8AFWL9W1589434
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 21:02:21 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8AFWLAI023780
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 21:02:21 +0530
Message-ID: <48C7E87F.2080706@linux.vnet.ibm.com>
Date: Wed, 10 Sep 2008 08:32:15 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] memory.min_usage again
References: <20071204040934.44AF41D0BA3@siro.lan> <20080910084443.8F7D85ACE@siro.lan>
In-Reply-To: <20080910084443.8F7D85ACE@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
> hi,
> 
>> hi,
>>
>> here's a patch to implement memory.min_usage,
>> which controls the minimum memory usage for a cgroup.
>>
>> it works similarly to mlock;
>> global memory reclamation doesn't reclaim memory from
>> cgroups whose memory usage is below the value.
>> setting it too high is a dangerous operation.
>>

Looking through the code I am a little worried, what if every cgroup is below
minimum value and the system is under memory pressure, do we OOM, while we could
have easily reclaimed?

I would prefer to see some heuristics around such a feature, mostly around the
priority that do_try_to_free_pages() to determine how desperate we are for
reclaiming memory.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
