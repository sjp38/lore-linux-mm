Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id B89216B0164
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:24:45 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 04:24:44 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 77E0A38C8054
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:24:42 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q8OgKF178194
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:24:42 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q8OfEV026495
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 05:24:42 -0300
Date: Tue, 26 Jun 2012 16:24:39 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/5] mm/sparse: check size of struct mm_section
Message-ID: <20120626082439.GA1617@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120625160322.GE19810@tiehlicka.suse.cz>
 <20120625163522.GA5476@shangw>
 <20120626073913.GC6713@tiehlicka.suse.cz>
 <20120626074854.GA29491@shangw>
 <20120626080628.GE6713@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626080628.GE6713@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> >> >> In order to fully utilize the memory chunk allocated from bootmem
>> >> >> allocator, it'd better to assure memory sector descriptor won't run
>> >> >> across the boundary (PAGE_SIZE).
>> >
>> >OK, I misread this part of the changelog changelog.
>> >
>> 
>> I should have clarified that more clear :-)
>> 
>> >> >
>> >> >Why? The memory is continuous, right?
>> >> 
>> >> Yes, the memory is conginous and the capacity of specific entry
>> >> in mem_section[NR_SECTION_ROOTS] has been defined as follows:
>> >> 
>> >> 
>> >> #define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))
>> >> 
>> >> Also, the memory is prone to be allocated from bootmem by function
>> >> alloc_bootmem_node(), which has PAGE_SIZE alignment. So I think it's
>> >> reasonable to introduce the extra check here from my personal view :-)
>> >
>> >No it is not necessary because we will never cross the page boundary
>> >because (SECTIONS_PER_ROOT uses an int division)
>> 
>> Current situation is that we don't cross the page foundary, but somebody
>> else might change the data struct (struct mem_section) in future. 
>
>No, this is safe even if the structure size changes (unless it is bigger
>than PAGE_SIZE).

Yeah, but it can't fully utilize the allocated memory chunk if the size of
the struct isn't aligned well.

Let me drop it in next revision :-)

Thanks,
Gavin


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
