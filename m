Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9787C6B0039
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 13:03:16 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so927595eek.29
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:03:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si3586508eep.167.2014.04.08.10.03.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 10:03:15 -0700 (PDT)
Date: Tue, 8 Apr 2014 18:03:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
Message-ID: <20140408170310.GO7292@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
 <53440A5D.6050301@zytor.com>
 <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
 <20140408164652.GL7292@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140408164652.GL7292@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 08, 2014 at 05:46:52PM +0100, Mel Gorman wrote:
> On Tue, Apr 08, 2014 at 08:22:15AM -0700, Linus Torvalds wrote:
> > On Tue, Apr 8, 2014 at 7:40 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> > >
> > > David, is your patchset going to be pushed in this merge window as expected?
> > 
> > Apparently aiming for 3.16 right now.
> > 
> 
> > > That being said, these bits are precious, and if this ends up being a
> > > case where "only Xen needs another bit" once again then Xen should
> > > expect to get kicked to the curb at a moment's notice.
> > 
> > Quite frankly, I don't think it's a Xen-only issue. The code was hard
> > to figure out even without the Xen issues. For example, nobody ever
> > explained to me why it
> > 
> >  (a) could be the same as PROTNONE on x86
> >  (b) could not be the same as PROTNONE in general
> 
> This series exists in response to your comment
> 
> 	I fundamentally think that it was a horrible horrible disaster to
> 	make _PAGE_NUMA alias onto _PAGE_PROTNONE.
> 
> As long as _PAGE_NUMA aliases to _PAGE_PROTNONE on x86 then the core has to
> play games to take that into account and the code will be "hard to figure
> out even without the Xen issues".

Is what you want for _PAGE_NUMA to disappear from arch/x86 and instead
use _PAGE_PROTNONE with comments explaining why and leave the core as it
is?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
