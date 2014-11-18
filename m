Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9306B006E
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 12:14:18 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so6149522wgg.21
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 09:14:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df6si22056584wib.106.2014.11.18.09.14.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 09:14:17 -0800 (PST)
Date: Tue, 18 Nov 2014 17:14:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
Message-ID: <20141118171413.GE2725@suse.de>
References: <1415971986-16143-1-git-send-email-mgorman@suse.de>
 <5466C8A5.3000402@oracle.com>
 <20141118154246.GB2725@suse.de>
 <546B74F5.10004@oracle.com>
 <87tx1w78hi.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87tx1w78hi.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Nov 18, 2014 at 10:26:41PM +0530, Aneesh Kumar K.V wrote:
> Sasha Levin <sasha.levin@oracle.com> writes:
> 
> > On 11/18/2014 10:42 AM, Mel Gorman wrote:
> >> 1. I'm assuming this is a KVM setup but can you confirm?
> >
> > Yes.
> >
> >> 2. Are you using numa=fake=N?
> >
> > Yes. numa=fake=24, which is probably way more nodes on any physical machine
> > than the new code was tested on?
> >
> >> 3. If you are using fake NUMA, what happens if you boot without it as
> >>    that should make the patches a no-op?
> >
> > Nope, still seeing it without fake numa.
> >
> >> 4. Similarly, does the kernel boot properly without without patches?
> >
> > Yes, the kernel works fine without the patches both with and without fake
> > numa.
> 
> 
> Hmm that is interesting. I am not sure how writeback_fid can be
> related. We use writeback fid to enable client side caching with 9p
> (cache=loose). We use this fid to write back dirty pages later. Can you
> share the qemu command line used, 9p mount options and the test details ? 
> 

It would help if the test details included the kernel config. I got KVM
working again on an server with an older installation and while it
doesn't use 9p, I'm not seeing any other oddities either yet while
running trinity.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
