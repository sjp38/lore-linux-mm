Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C5C8A6B0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 19:26:05 -0500 (EST)
Received: by mail-da0-f52.google.com with SMTP id f10so1256741dak.39
        for <linux-mm@kvack.org>; Thu, 14 Feb 2013 16:26:05 -0800 (PST)
Date: Thu, 14 Feb 2013 16:26:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
In-Reply-To: <511C61AD.2010702@gmail.com>
Message-ID: <alpine.DEB.2.02.1302141624430.27961@chino.kir.corp.google.com>
References: <bug-53501-27@https.bugzilla.kernel.org/> <20130212165107.32be0c33.akpm@linux-foundation.org> <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com> <20130212195929.7cd2e597.akpm@linux-foundation.org> <alpine.DEB.2.02.1302131915170.8584@chino.kir.corp.google.com>
 <511C61AD.2010702@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Thu, 14 Feb 2013, Jiang Liu wrote:

> > Hmm, ok.  The question is which one is right: the per-node MemTotal is the 
> > amount of present RAM, the spanned range minus holes, and the system 
> > MemTotal is the amount of pages released to the buddy allocator by 
> > bootmem and discounts not only the memory holes but also reserved pages.  
> > Should they both be the amount of RAM present or the amount of unreserved 
> > RAM present?
> > 
> Hi David,
> 	We have worked out a patch set to address this issue. The first two
> patches have been merged into v3.8, and another two patches are queued in
> Andrew's mm tree for v3.9.
> 	The patch set introduces a new field named managed_pages into struct
> zone to distinguish between pages present in a zone and pages managed by the
> buddy system. So
> zone->present_pages = zone->spanned_pages - pages_in_hole;
> zone->managed_pages = pages_managed_by_buddy_system_in_the_zone;
> 	We have also added a field named "managed" into /proc/zoneinfo, but
> haven't touch /proc/meminfo and /sys/devices/system/node/nodex/meminfo yet.
> If preferred, we could work out another patch to enhance these two files
> as suggested above.

I'm glad this is a known issue that you're working on, but my question 
still stands: if MemTotal is going to be consistent throughout 
/proc/meminfo and /sys/devices/system/node/nodeX/meminfo, which is 
correct?  The present RAM minus holes or the amount available to the buddy 
allocator not including reserved memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
