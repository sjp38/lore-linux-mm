Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CEE776B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 18:44:45 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so4357162wiw.8
        for <linux-mm@kvack.org>; Tue, 06 May 2014 15:44:45 -0700 (PDT)
Received: from mx4-phx2.redhat.com (mx4-phx2.redhat.com. [209.132.183.25])
        by mx.google.com with ESMTP id l7si4996351wie.71.2014.05.06.15.44.42
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 15:44:43 -0700 (PDT)
Date: Tue, 6 May 2014 18:44:08 -0400 (EDT)
From: David Airlie <airlied@redhat.com>
Message-ID: <1960794033.1414346.1399416248431.JavaMail.zimbra@redhat.com>
In-Reply-To: <CA+55aFwQWRKpcaR_-GvhMbUXE-n5yjEi_a_Um7=Bb_xbdQtFFg@mail.gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com> <CA+55aFzt47Jpp-KK-ocLGgzYt_w-vheqFLfaGZOUSjwVrgGUtw@mail.gmail.com> <20140506150014.GA6731@gmail.com> <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com> <20140506153315.GB6731@gmail.com> <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com> <53690E29.7060602@redhat.com> <CA+55aFwQWRKpcaR_-GvhMbUXE-n5yjEi_a_Um7=Bb_xbdQtFFg@mail.gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Jerome Glisse <j.glisse@gmail.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>


> 
> On Tue, May 6, 2014 at 9:30 AM, Rik van Riel <riel@redhat.com> wrote:
> >
> > The GPU runs a lot faster when using video memory, instead
> > of system memory, on the other side of the PCIe bus.
> 
> The nineties called, and they want their old broken model back.
> 
> Get with the times. No high-performance future GPU will ever run
> behind the PCIe bus. We still have a few straggling historical
> artifacts, but everybody knows where the future is headed.
> 
> They are already cache-coherent because flushing caches etc was too
> damn expensive. They're getting more so.

The future might be closer coupled, but it still might not be cache coherent, it might also just be a faster PCIE, considering the current one is a lot faster than the 90s PCI you talk about.

No current high-performance GPU runs in front of the PCIe bus, Intel are still catching up to the performance level of anyone else and others still remain ahead. Even intel make MIC cards for compute that put stuff on the other side of the PCIE divide.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
