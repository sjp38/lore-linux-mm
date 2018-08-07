Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0963D6B000E
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 10:28:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h14-v6so11545744wmb.4
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 07:28:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14-v6sor466452wmc.12.2018.08.07.07.28.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 07:28:27 -0700 (PDT)
Date: Tue, 7 Aug 2018 16:28:26 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 0/3] Do not touch pages in remove_memory path
Message-ID: <20180807142826.GB5309@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <6407d022-87b7-f5e0-572a-c5c29aba1314@redhat.com>
 <20180807141922.GA5244@techadventures.net>
 <d0ea36f7-9329-f947-3862-011827aee20c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d0ea36f7-9329-f947-3862-011827aee20c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, jglisse@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 07, 2018 at 04:20:37PM +0200, David Hildenbrand wrote:
> On 07.08.2018 16:19, Oscar Salvador wrote:
> > On Tue, Aug 07, 2018 at 04:16:35PM +0200, David Hildenbrand wrote:
> >> On 07.08.2018 15:37, osalvador@techadventures.net wrote:
> >>> From: Oscar Salvador <osalvador@suse.de>
> >>>
> >>> This tries to fix [1], which was reported by David Hildenbrand, and also
> >>> does some cleanups/refactoring.
> >>>
> >>> I am sending this as RFC to see if the direction I am going is right before
> >>> spending more time into it.
> >>> And also to gather feedback about hmm/zone_device stuff.
> >>> The code compiles and I tested it successfully with normal memory-hotplug operations.
> >>>
> >>
> >> Please coordinate next time with people already working on this,
> >> otherwise you might end up wasting other people's time.
> > 
> > Hi David,
> > 
> > Sorry, if you are already working on this, I step back immediately.
> > I will wait for your work.
> 
> No, please keep going, you are way ahead of me ;)
> 
> (I was got stuck at ZONE_DEVICE so far)

It seems mine breaks ZONE_DEVICE for hmm at least, so.. not much better ^^.
So since you already got some work, let us not throw it away.

Thanks
-- 
Oscar Salvador
SUSE L3
