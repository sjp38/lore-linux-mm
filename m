Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC758299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 19:44:15 -0400 (EDT)
Received: by qcto4 with SMTP id o4so2040201qct.3
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 16:44:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 25si3330975qku.46.2015.03.13.16.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 16:44:14 -0700 (PDT)
Message-ID: <55037631.3010402@redhat.com>
Date: Fri, 13 Mar 2015 19:43:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
References: <1426267597-25811-1-git-send-email-emunson@akamai.com> <550332CE.7040404@redhat.com> <20150313190915.GA12589@akamai.com> <alpine.DEB.2.10.1503131613560.7827@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503131613560.7827@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/13/2015 07:18 PM, David Rientjes wrote:
> On Fri, 13 Mar 2015, Eric B Munson wrote:
> 
>>>> --- a/mm/compaction.c
>>>> +++ b/mm/compaction.c
>>>> @@ -1046,6 +1046,8 @@ typedef enum {
>>>>  	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
>>>>  } isolate_migrate_t;
>>>>  
>>>> +int sysctl_compact_unevictable;
>>>> +
>>>>  /*
>>>>   * Isolate all pages that can be migrated from the first suitable block,
>>>>   * starting at the block pointed to by the migrate scanner pfn within
>>>
>>> I suspect that the use cases where users absolutely do not want
>>> unevictable pages migrated are special cases, and it may make
>>> sense to enable sysctl_compact_unevictable by default.
>>
>> Given that sysctl_compact_unevictable=0 is the way the kernel behaves
>> now and the push back against always enabling compaction on unevictable
>> pages, I left the default to be the behavior as it is today.  I agree
>> that this is likely the minority case, but I'd really like Peter Z or
>> someone else from real time to say that they are okay with the default
>> changing.
>>
> 
> It would be really disappointing to not enable this by default for !rt 
> kernels.  We haven't migrated mlocked pages in the past by way of memory 
> compaction because it can theoretically result in consistent minor page 
> faults, but I haven't yet heard a !rt objection to enabling this.
> 
> If the rt patchset is going to carry a patch to disable this

It does not have to carry a patch to disable something that can be
disabled at run time.

The smaller the realtime patchset has to be, the better.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
