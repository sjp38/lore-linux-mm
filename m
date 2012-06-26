Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9D8AD6B0148
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:17:28 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 01:17:28 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 793703E4004C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 07:17:24 +0000 (WET)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q7HP9c207926
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:17:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q7HOO8022771
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:17:24 -0600
Date: Tue, 26 Jun 2012 15:17:21 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] mm/sparse: fix possible memory leak
Message-ID: <20120626071721.GA23641@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-3-git-send-email-shangw@linux.vnet.ibm.com>
 <20120625154851.GD19810@tiehlicka.suse.cz>
 <20120626061147.GB9483@shangw>
 <20120626071436.GB6713@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626071436.GB6713@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> >> With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
>> >> are allocated by slab or bootmem allocator. Also, the descriptors
>> >> might have been allocated and initialized by others. However, the
>> >> memory chunk allocated in current implementation wouldn't be put
>> >> into the available pool if others have allocated memory chunk for
>> >> that.
>> >
>> >Who is others? I assume that we can race in hotplug because other than
>> >that this is an early initialization code. How can others race?
>> >
>> 
>> I'm sorry that I don't have the real bug against the issue. 
>
>I am not saying the bug is not real. It is just that the changelog
>doesn's say how the bug is hit, who is affected and when it has been
>introduced. These is essential for stable.
>

Thanks, Michal. Let me replace "others" with "hotplug" in next revision :-)

Thanks,
Gavin

>
>-- 
>Michal Hocko
>SUSE Labs
>SUSE LINUX s.r.o.
>Lihovarska 1060/12
>190 00 Praha 9    
>Czech Republic
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
