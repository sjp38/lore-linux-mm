Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 56AEA6B0156
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:49:04 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 01:49:03 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id AA01919D804F
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 07:48:55 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q7mwRV268030
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:48:58 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q7mwTp009476
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:48:58 -0600
Date: Tue, 26 Jun 2012 15:48:54 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/5] mm/sparse: check size of struct mm_section
Message-ID: <20120626074854.GA29491@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120625160322.GE19810@tiehlicka.suse.cz>
 <20120625163522.GA5476@shangw>
 <20120626073913.GC6713@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626073913.GC6713@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> >> In order to fully utilize the memory chunk allocated from bootmem
>> >> allocator, it'd better to assure memory sector descriptor won't run
>> >> across the boundary (PAGE_SIZE).
>
>OK, I misread this part of the changelog changelog.
>

I should have clarified that more clear :-)

>> >
>> >Why? The memory is continuous, right?
>> 
>> Yes, the memory is conginous and the capacity of specific entry
>> in mem_section[NR_SECTION_ROOTS] has been defined as follows:
>> 
>> 
>> #define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))
>> 
>> Also, the memory is prone to be allocated from bootmem by function
>> alloc_bootmem_node(), which has PAGE_SIZE alignment. So I think it's
>> reasonable to introduce the extra check here from my personal view :-)
>
>No it is not necessary because we will never cross the page boundary
>because (SECTIONS_PER_ROOT uses an int division)

Current situation is that we don't cross the page foundary, but somebody
else might change the data struct (struct mem_section) in future. It will
trigger warning at build time to alarm that the struct should fit with
page size.

Anyway, I will drop this in next revision if you want keep as of being.
Otherwise, I will include it in next revision :-)

Thanks for your time, Michal.

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
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
