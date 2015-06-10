Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id BC4666B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:17:08 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so40146993wiw.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:17:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tn8si16329553wjc.133.2015.06.10.01.17.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 01:17:07 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:17:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] mm: Defer flush of writable TLB entries
Message-ID: <20150610081703.GZ26425@suse.de>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-4-git-send-email-mgorman@suse.de>
 <20150610075033.GB18049@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150610075033.GB18049@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 10, 2015 at 09:50:34AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > +
> > +	/*
> > +	 * If the PTE was dirty then it's best to assume it's writable. The
> > +	 * caller must use try_to_unmap_flush_dirty() or try_to_unmap_flush()
> > +	 * before the page any IO is initiated.
> > +	 */
> 
> Speling nit: "before the page any IO is initiated" does not parse for me.
> 
> > +			/*
> > +			 * Page is dirty. Flush the TLB if a writable entry
> > +			 * potentially exists to avoid CPU writes after IO
> > +			 * starts and then write it out here
> > +			 */
> 
> s/here/here.
> 
> or:
> 
> s/here/here:
> 

Both fixed, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
