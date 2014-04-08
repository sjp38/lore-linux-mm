Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id E01C36B0037
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:12:16 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id rl12so1138153iec.22
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:12:16 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ks1si3994455igb.3.2014.04.08.09.12.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 09:12:16 -0700 (PDT)
Date: Tue, 8 Apr 2014 18:12:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
Message-ID: <20140408161203.GQ10526@twins.programming.kicks-ass.net>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
 <53440A5D.6050301@zytor.com>
 <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 08, 2014 at 08:22:15AM -0700, Linus Torvalds wrote:
> On Tue, Apr 8, 2014 at 7:40 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> >
> > David, is your patchset going to be pushed in this merge window as expected?
> 
> Apparently aiming for 3.16 right now.
> 
> > That being said, these bits are precious, and if this ends up being a
> > case where "only Xen needs another bit" once again then Xen should
> > expect to get kicked to the curb at a moment's notice.
> 
> Quite frankly, I don't think it's a Xen-only issue. The code was hard
> to figure out even without the Xen issues. For example, nobody ever
> explained to me why it
> 
>  (a) could be the same as PROTNONE on x86
>  (b) could not be the same as PROTNONE in general
> 
> I think the best explanation for it so far was from the little voices
> in my head that sang "It's a kind of Magic", and that isn't even
> remotely the best song by Queen.

Right; so initially when I started doing the numa scanning thing I
implemented b. I've never quite understood why that wasn't chosen; but
since Mel already got the PAGE_NUMA bits merged by the time I
re-surfaced, I didn't want to argue too much about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
