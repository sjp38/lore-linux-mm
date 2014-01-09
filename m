Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0C52F6B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 20:35:57 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so2326567pbb.23
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 17:35:57 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nu8si2197123pbb.162.2014.01.08.17.35.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 17:35:56 -0800 (PST)
Message-ID: <52CDFCF1.5060107@oracle.com>
Date: Thu, 09 Jan 2014 09:35:45 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Persistent Memory
References: <20131220170502.GF19166@parisc-linux.org> <20140108154259.GJ27046@suse.de>
In-Reply-To: <20140108154259.GJ27046@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Matthew Wilcox <matthew@wil.cx>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org


On 01/08/2014 11:42 PM, Mel Gorman wrote:
> On Fri, Dec 20, 2013 at 10:05:02AM -0700, Matthew Wilcox wrote:
>>
>> I should like to discuss the current situation with Linux support for
>> persistent memory.  While I expect the current discussion to be long
>> over by March, I am certain that there will be topics around persistent
>> memory that have not been settled at that point.
>>
>> I believe this will mostly be of crossover interest between filesystem
>> and MM people, and of lesser interest to storage people (since we're
>> basically avoiding their code).
>>
>> Subtopics might include
>>  - Using persistent memory for FS metadata
>>    (The XIP code provides persistent memory to userspace.  The filesystem
>>     still uses BIOs to fetch its metadata)
>>  - Supporting PMD/PGD mappings for userspace
>>    (Not only does the filesystem have to avoid fragmentation to make this
>>     happen, the VM code has to permit these giant mappings)
> 
> The filesystem would also have to correctly align the data on disk. All
> this implies that the underlying device is byte-addressible, similar access
> speeds to RAM and directly accessible from userspace without the kernel
> being involved. Without those conditions, I find it hard to believe that
> TLB pressure dominates access cost. Then again I have no experience with
> the devices or their intended use case so would not mind an education.
> 
> However, if you really wanted the device to be accessible like this then
> the shortest solutions (and I want to punch myself for even suggesting
> this) is to extend hugetlbfs to directly access these devices. It's
> almost certainly a bad direction to take though, there would need to be a
> good justification for it. Anything in this direction is pushing usage of
> persistent devices to userspace and the kernel just provides an interface,
> maybe that is desirable maybe not.
> 
>>  - Persistent page cache
>>    (Another way to take advantage of persstent memory would be to place it
>>     in the page cache.  But we don't have struct pages for it!  What to do?)
> 

I think one potential way is to use persistent memory as a second-level
clean page cache through the cleancache API.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
