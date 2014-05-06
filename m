Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id B842D6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 13:43:23 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id hr9so1410211vcb.31
        for <linux-mm@kvack.org>; Tue, 06 May 2014 10:43:23 -0700 (PDT)
Received: from mail-ve0-x232.google.com (mail-ve0-x232.google.com [2607:f8b0:400c:c01::232])
        by mx.google.com with ESMTPS id sa1si1054725vdb.124.2014.05.06.10.43.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 10:43:22 -0700 (PDT)
Received: by mail-ve0-f178.google.com with SMTP id sa20so4692046veb.37
        for <linux-mm@kvack.org>; Tue, 06 May 2014 10:43:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140506172853.GF6731@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	<20140506102925.GD11096@twins.programming.kicks-ass.net>
	<CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>
	<20140506150014.GA6731@gmail.com>
	<CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
	<20140506153315.GB6731@gmail.com>
	<CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
	<20140506161836.GC6731@gmail.com>
	<CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
	<20140506172853.GF6731@gmail.com>
Date: Tue, 6 May 2014 10:43:22 -0700
Message-ID: <CA+55aFwhHYnVhzx4-TchrpM5AN2Oqm1fy8ot0bguJ=T_eeA0fg@mail.gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 6, 2014 at 10:28 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
>
> Also, just to be sure, are my changes to the radix tree otherwise
> acceptable at least in principle.

It looks like it adds several "loop over each page" cases just to
check whether each page might be on remote memory.

Which seems a complete waste of time 99.99% of the time.

But maybe I'm looking at the wrong patch.

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
