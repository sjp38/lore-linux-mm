Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B513C6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 00:21:19 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so3335569dak.6
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 21:21:19 -0800 (PST)
Message-ID: <51245D48.4030102@gmail.com>
Date: Wed, 20 Feb 2013 13:21:12 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
References: <bug-53501-27@https.bugzilla.kernel.org/> <20130212165107.32be0c33.akpm@linux-foundation.org> <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com> <20130212195929.7cd2e597.akpm@linux-foundation.org> <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com> <511C61AD.2010702@gmail.com> <alpine.DEB.2.02.1302141624430.27961@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1302141624430.27961@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Hi David,
On 02/15/2013 08:26 AM, David Rientjes wrote:
> On Thu, 14 Feb 2013, Jiang Liu wrote:
>
>>> Hmm, ok.  The question is which one is right: the per-node MemTotal is the
>>> amount of present RAM, the spanned range minus holes, and the system
>>> MemTotal is the amount of pages released to the buddy allocator by
>>> bootmem and discounts not only the memory holes but also reserved pages.
>>> Should they both be the amount of RAM present or the amount of unreserved
>>> RAM present?
>>>
>> Hi David,
>> 	We have worked out a patch set to address this issue. The first two
>> patches have been merged into v3.8, and another two patches are queued in
>> Andrew's mm tree for v3.9.
>> 	The patch set introduces a new field named managed_pages into struct
>> zone to distinguish between pages present in a zone and pages managed by the
>> buddy system. So
>> zone->present_pages = zone->spanned_pages - pages_in_hole;
>> zone->managed_pages = pages_managed_by_buddy_system_in_the_zone;
>> 	We have also added a field named "managed" into /proc/zoneinfo, but
>> haven't touch /proc/meminfo and /sys/devices/system/node/nodex/meminfo yet.
>> If preferred, we could work out another patch to enhance these two files
>> as suggested above.
> I'm glad this is a known issue that you're working on, but my question
> still stands: if MemTotal is going to be consistent throughout
> /proc/meminfo and /sys/devices/system/node/nodeX/meminfo, which is
> correct?  The present RAM minus holes or the amount available to the buddy
> allocator not including reserved memory?

What I confuse is why have /proc/meminfo and /proc/vmstat at the same 
time, they both use to monitor memory subsystem states. What's the root 
reason?

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
