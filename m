Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9706B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:47:56 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so2552129eek.18
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:47:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v2si13892697eel.256.2014.05.06.09.47.54
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 09:47:55 -0700 (PDT)
Message-ID: <53691214.80906@redhat.com>
Date: Tue, 06 May 2014 12:47:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>	<20140506102925.GD11096@twins.programming.kicks-ass.net>	<CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com>	<20140506150014.GA6731@gmail.com>	<CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>	<20140506153315.GB6731@gmail.com>	<CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>	<53690E29.7060602@redhat.com> <CA+55aFwQWRKpcaR_-GvhMbUXE-n5yjEi_a_Um7=Bb_xbdQtFFg@mail.gmail.com>
In-Reply-To: <CA+55aFwQWRKpcaR_-GvhMbUXE-n5yjEi_a_Um7=Bb_xbdQtFFg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On 05/06/2014 12:34 PM, Linus Torvalds wrote:
> On Tue, May 6, 2014 at 9:30 AM, Rik van Riel <riel@redhat.com> wrote:
>>
>> The GPU runs a lot faster when using video memory, instead
>> of system memory, on the other side of the PCIe bus.
> 
> The nineties called, and they want their old broken model back.
> 
> Get with the times. No high-performance future GPU will ever run
> behind the PCIe bus. We still have a few straggling historical
> artifacts, but everybody knows where the future is headed.
> 
> They are already cache-coherent because flushing caches etc was too
> damn expensive. They're getting more so.

I suppose that VRAM could simply be turned into a very high
capacity CPU cache for the GPU, for the case where people
want/need an add-on card.

With a few hundred MB of "CPU cache" on the video card, we
could offload processing to the GPU very easily, without
having to worry about multiple address or page table formats
on the CPU side.

A new generation of GPU hardware seems to come out every
six months or so, so I guess we could live with TLB
invalidations to the first generations of hardware being
comically slow :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
