Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2BA466B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 04:40:40 -0400 (EDT)
Message-ID: <4A5314BF.5010607@redhat.com>
Date: Tue, 07 Jul 2009 12:26:23 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>	<20090707084750.GX2714@wotan.suse.de>	<4A530FD4.7060606@redhat.com> <20090707181829.10d48272.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090707181829.10d48272.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 07/07/2009 12:18 PM, KAMEZAWA Hiroyuki wrote:
>> For kvm live migration, I've thought of extending mincore() to report if
>> a page will be read as zeros.
>>
>>      
> BTW, ksm can scale enough to combine all pages which just includes zero ?
> No heavy cache ping-pong without zero-page ?
>    

ksm will increase cpu and cache load; it's oriented towards workloads 
where reducing memory pressure is more important than cpu load.  For 
cpu-intensive, low sharing workloads it will be disabled.  That's why I 
want an alternative way to deal with zero pages; it can be ZERO_PAGE, 
mincore(), or madvise(MADV_DROP_IFZERO).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
