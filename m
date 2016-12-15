Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB1C6B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 13:29:42 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so26239849wjc.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 10:29:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f84si3901893wmi.127.2016.12.15.10.29.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 10:29:40 -0800 (PST)
Subject: Re: [PATCH] MAINTAINERS, mm: add IRC info and update include file
 list
References: <20161215080848.18070-1-vbabka@suse.cz>
 <20161215140321.GB27758@node>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4d2dcb5e-3908-880c-e8a7-128765f70b91@suse.cz>
Date: Thu, 15 Dec 2016 19:29:36 +0100
MIME-Version: 1.0
In-Reply-To: <20161215140321.GB27758@node>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 15.12.2016 15:03, Kirill A. Shutemov wrote:
> On Thu, Dec 15, 2016 at 09:08:48AM +0100, Vlastimil Babka wrote:
>> There's a new C: entry for IRC or similar chat, so add the OFTC #mm channel.
>> While at it, add more F: entries for least the more prominent include/ files
>> related to mm.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  MAINTAINERS | 16 ++++++++++++++++
>>  1 file changed, 16 insertions(+)
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 59c9895d73d5..fd1ac4bfc2cd 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -3355,6 +3355,7 @@ M:	Vladimir Davydov <vdavydov.dev@gmail.com>
>>  L:	cgroups@vger.kernel.org
>>  L:	linux-mm@kvack.org
>>  S:	Maintained
>> +F:	include/linux/memcontrol.h
>>  F:	mm/memcontrol.c
>>  F:	mm/swap_cgroup.c
>>  
>> @@ -8058,12 +8059,27 @@ F:	include/uapi/linux/membarrier.h
>>  MEMORY MANAGEMENT
>>  L:	linux-mm@kvack.org
>>  W:	http://www.linux-mm.org
>> +C:	irc://irc.oftc.net/mm
>>  S:	Maintained
>>  F:	include/linux/mm.h
>> +F:	include/linux/mm_types.h
>> +F:	include/linux/mm_inline.h
>> +F:	include/linux/mmdebug.h
>> +F:	include/linux/compaction.h
>> +F:	include/linux/oom.h
>>  F:	include/linux/gfp.h
>>  F:	include/linux/mmzone.h
>>  F:	include/linux/memory_hotplug.h
>> +F:	include/linux/mempolicy.h
>> +F:	include/linux/page-isolation.h
>> +F:	include/linux/page_ext.h
>> +F:	include/linux/page_owner.h
>> +F:	include/linux/migrate.h
>> +F:	include/linux/hugetlb.h
>> +F:	include/linux/rmap.h
>>  F:	include/linux/vmalloc.h
>> +F:	include/linux/vmstat.h
>> +F:	include/linux/vm_event_item.h
> 
> Maybe sort the list?
> 
> And the it is still incomplete very incomplete: huge_mm.h, page-flags*,
> mman.h, etc.

Hmm I see.
I wonder if this kind of list scales at all, and how much do we care to have it
complete. Maybe we could use some special keyword with K: and mark the include
files by that instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
