Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id D88836B0036
	for <linux-mm@kvack.org>; Wed,  7 May 2014 13:34:38 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id m1so1670737oag.0
        for <linux-mm@kvack.org>; Wed, 07 May 2014 10:34:38 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id ta10si11301285obc.150.2014.05.07.10.34.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 May 2014 10:34:38 -0700 (PDT)
Message-ID: <1399484069.4567.5.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 07 May 2014 10:34:29 -0700
In-Reply-To: <20140507130032.GM30445@twins.programming.kicks-ass.net>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	 <20140506102925.GD11096@twins.programming.kicks-ass.net>
	 <1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
	 <20140507130032.GM30445@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: j.glisse@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander,
 Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman,
 John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 2014-05-07 at 15:00 +0200, Peter Zijlstra wrote:
> On Tue, May 06, 2014 at 07:33:07PM -0700, Davidlohr Bueso wrote:
> 
> > So I've been running benchmarks (mostly aim7, which nicely exercises our
> > locks) comparing my recent v4 for rwsem optimistic spinning against
> > previous implementation ideas for the anon-vma lock, mostly:
> 
> > - rwlock_t
> > - qrwlock_t
> 
> Which reminds me; can you provide the numbers for rwlock_t vs qrwlock_t
> in a numeric form so I can include them in the qrwlock_t changelog.

Ah, right. I was lazy and just showed you the graphs.

> That way I can queue those patches for inclusion, I think we want a fair
> rwlock_t if we can show (and you graphs do iirc) that it doesn't cost us
> performance.

I agree, fairness is much welcome here. And I agree that despite my good
numbers, and that we should keep the anon vma lock as a rwsem, its still
worth merging the qrwlock stuff. I'll cookup my regular numeric table
today.

Thanks,
Davidlohr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
