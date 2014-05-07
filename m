Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id CE3E76B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 03:20:17 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so619896qge.22
        for <linux-mm@kvack.org>; Wed, 07 May 2014 00:20:17 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 105si6350199qgw.110.2014.05.07.00.20.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 May 2014 00:20:16 -0700 (PDT)
Message-ID: <1399447116.4161.36.camel@pasglop>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 07 May 2014 17:18:36 +1000
In-Reply-To: <CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	 <20140506102925.GD11096@twins.programming.kicks-ass.net>
	 <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
	 <20140506150014.GA6731@gmail.com>
	 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
	 <20140506153315.GB6731@gmail.com>
	 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
	 <20140506161836.GC6731@gmail.com>
	 <CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander,
 Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, 2014-05-06 at 09:32 -0700, Linus Torvalds wrote:
> and what I think a GPU flush has to do is to do the actual flushes
> when asked to (because that's what it will need to do to work with a
> real TLB eventually), but if there's some crazy asynchronous
> acknowledge thing from hardware, it's possible to perhaps wait for
> that in the final phase (*before* we free the pages we gathered).

Hrm, difficult. We have some pretty strong assumptions that
ptep_clear_flush() is fully synchronous as far as I can tell... ie, your
trick would work for the unmap case but everything else is still
problematic.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
