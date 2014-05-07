Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 10DFA6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 12:21:05 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id ld13so1036697vcb.40
        for <linux-mm@kvack.org>; Wed, 07 May 2014 09:21:04 -0700 (PDT)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id fa16si2990831veb.136.2014.05.07.09.21.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 09:21:04 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id ld13so1041416vcb.26
        for <linux-mm@kvack.org>; Wed, 07 May 2014 09:21:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
	<20140506102925.GD11096@twins.programming.kicks-ass.net>
	<1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
Date: Wed, 7 May 2014 09:21:03 -0700
Message-ID: <CA+55aFysZyb1N9sC6ieRYbfGO6ATXT2eAe0-RbWcUoCHko8gFw@mail.gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Jerome Glisse <j.glisse@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>

On Tue, May 6, 2014 at 7:33 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
=>
> What is perhaps not so obvious is that rwsem+optimistic spinning beats
> all others, including the improved qrwlock from Waiman and Peter. This
> is mostly because of the idea of cancelable MCS, which was mimic'ed from
> mutexes. The delta in most cases is around +10-15%, which is non
> trivial.

Ahh, excellent news. That way I don't have to worry about the anonvma
lock any more. I'll just forget about it right now, in fact.

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
