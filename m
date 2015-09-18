Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7326B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 06:11:57 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so57692353wic.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 03:11:56 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id ly8si3893306wic.103.2015.09.18.03.11.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Sep 2015 03:11:55 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 18 Sep 2015 11:11:55 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 86E36219005F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 11:11:23 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8IABqQd40173642
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 10:11:52 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8IABqvl022039
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 04:11:52 -0600
Date: Fri, 18 Sep 2015 12:11:50 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150918121150.34cf4f54@mschwide>
In-Reply-To: <20150918092827.GD2035@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
	<1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
	<20150917193152.GJ2000@uranus>
	<20150918085835.597fb036@mschwide>
	<20150918071549.GA2035@uranus>
	<20150918102001.0e0389c7@mschwide>
	<20150918085301.GC2035@uranus>
	<20150918111038.58c3a8de@mschwide>
	<20150918092827.GD2035@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, 18 Sep 2015 12:28:27 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Fri, Sep 18, 2015 at 11:10:38AM +0200, Martin Schwidefsky wrote:
> > > 
> > > You know, these are only two lines where we use _PAGE_SOFT_DIRTY
> > > directly, so I don't see much point in adding 22 lines of code
> > > for that. Maybe we can leave it as is?
> >  
> > Only x86 has pte_clear_flags. And the two lines require that there is exactly
> > one bit in the PTE for soft-dirty. An alternative encoding will not be allowed.
> > And the current set of primitives is asymmetric, there are functions to query
> > and set the bit pte_soft_dirty and pte_mksoft_dirty but no function to clear
> > the bit.
> 
> OK, Martin, gimme some time please, I don't have code at my hands, so once
> I'm back, I'll take a precise look, ok?

Sure, thanks.
 
-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
