Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78ADB6B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:09:35 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 63so8902150wrn.7
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 00:09:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p21sor2537915wmc.37.2018.02.14.00.09.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 00:09:34 -0800 (PST)
Date: Wed, 14 Feb 2018 09:09:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 0/4] optimize memory hotplug
Message-ID: <20180214080930.n44x3arzqanja5zq@gmail.com>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213135359.705680d373a482b650f38b50@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180213135359.705680d373a482b650f38b50@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 13 Feb 2018 14:31:55 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> 
> > This patchset:
> > - Improves hotplug performance by eliminating a number of
> > struct page traverses during memory hotplug.
> > 
> > - Fixes some issues with hotplugging, where boundaries
> > were not properly checked. And on x86 block size was not properly aligned
> > with end of memory
> > 
> > - Also, potentially improves boot performance by eliminating condition from
> >   __init_single_page().
> > 
> > - Adds robustness by verifying that that struct pages are correctly
> >   poisoned when flags are accessed.
> 
> I'm now attempting to get a 100% review rate on MM patches, which is
> why I started adding my Reviewed-by: when I do that thing.
> 
> I'm not familiar enough with this code to add my own Reviewed-by:, and
> we'll need to figure out what to do in such cases.  I shall be sending
> out periodic review-status summaries.
> 
> If you're able to identify a suitable reviewer for this work and to
> offer them beer, that would help.  Let's see what happens as the weeks
> unfold.

The largest patch, fix patch #2, looks good to me and fixes a real bug.
Patch #1 and #3 also look good to me (assuming the runtime overhead
added by patch #3 is OK to you):

  Reviewed-by: Ingo Molnar <mingo@kernel.org>

(I suspect patch #1 and patch #2 should also get a Cc: stable.)

Patch #4 is too large to review IMO: it should be split up into as many patches as 
practically possible. That will also help bisectability, should anything break.

Before applying these patches please fix changelog and code comment spelling.

But it's all good stuff AFAICS!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
