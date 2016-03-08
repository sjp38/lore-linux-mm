Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 933A06B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 06:15:00 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id u110so8736955qge.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:15:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i6si2460448qgf.122.2016.03.08.03.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 03:14:59 -0800 (PST)
Date: Tue, 8 Mar 2016 16:44:43 +0530
From: Amit Shah <amit.shah@redhat.com>
Subject: Re: [RFC qemu 0/4] A PV solution for live migration optimization
Message-ID: <20160308111443.GN15443@grmbl.mre>
References: <1457083967-13681-1-git-send-email-jitendra.kolhe@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457083967-13681-1-git-send-email-jitendra.kolhe@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jitendra Kolhe <jitendra.kolhe@hpe.com>
Cc: liang.z.li@intel.com, dgilbert@redhat.com, ehabkost@redhat.com, kvm@vger.kernel.org, mst@redhat.com, quintela@redhat.com, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, linux-mm@kvack.org, pbonzini@redhat.com, akpm@linux-foundation.org, virtualization@lists.linux-foundation.org, rth@twiddle.net, mohan_parthasarathy@hpe.com, simhan@hpe.com

On (Fri) 04 Mar 2016 [15:02:47], Jitendra Kolhe wrote:
> > >
> > > * Liang Li (liang.z.li@intel.com) wrote:
> > > > The current QEMU live migration implementation mark the all the
> > > > guest's RAM pages as dirtied in the ram bulk stage, all these pages
> > > > will be processed and that takes quit a lot of CPU cycles.
> > > >
> > > > From guest's point of view, it doesn't care about the content in free
> > > > pages. We can make use of this fact and skip processing the free pages
> > > > in the ram bulk stage, it can save a lot CPU cycles and reduce the
> > > > network traffic significantly while speed up the live migration
> > > > process obviously.
> > > >
> > > > This patch set is the QEMU side implementation.
> > > >
> > > > The virtio-balloon is extended so that QEMU can get the free pages
> > > > information from the guest through virtio.
> > > >
> > > > After getting the free pages information (a bitmap), QEMU can use it
> > > > to filter out the guest's free pages in the ram bulk stage. This make
> > > > the live migration process much more efficient.
> > >
> > > Hi,
> > >   An interesting solution; I know a few different people have been looking at
> > > how to speed up ballooned VM migration.
> > >
> >
> > Ooh, different solutions for the same purpose, and both based on the balloon.
> 
> We were also tying to address similar problem, without actually needing to modify
> the guest driver. Please find patch details under mail with subject.
> migration: skip sending ram pages released by virtio-balloon driver

The scope of this patch series seems to be wider: don't send free
pages to a dest at all, vs. don't send pages that are ballooned out.

		Amit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
