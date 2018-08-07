Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 429C66B0008
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 10:19:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o25-v6so11516643wmh.1
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 07:19:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o63-v6sor403053wma.77.2018.08.07.07.19.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 07:19:24 -0700 (PDT)
Date: Tue, 7 Aug 2018 16:19:22 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 0/3] Do not touch pages in remove_memory path
Message-ID: <20180807141922.GA5244@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <6407d022-87b7-f5e0-572a-c5c29aba1314@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6407d022-87b7-f5e0-572a-c5c29aba1314@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 07, 2018 at 04:16:35PM +0200, David Hildenbrand wrote:
> On 07.08.2018 15:37, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> > 
> > This tries to fix [1], which was reported by David Hildenbrand, and also
> > does some cleanups/refactoring.
> > 
> > I am sending this as RFC to see if the direction I am going is right before
> > spending more time into it.
> > And also to gather feedback about hmm/zone_device stuff.
> > The code compiles and I tested it successfully with normal memory-hotplug operations.
> >
> 
> Please coordinate next time with people already working on this,
> otherwise you might end up wasting other people's time.

Hi David,

Sorry, if you are already working on this, I step back immediately.
I will wait for your work.

thanks
-- 
Oscar Salvador
SUSE L3
