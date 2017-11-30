Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1F4C6B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 13:39:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id m9so5465464pff.0
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:39:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6si380517pgn.792.2017.11.30.10.39.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 10:39:17 -0800 (PST)
Date: Thu, 30 Nov 2017 19:39:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mmap.2: document new MAP_FIXED_SAFE flag
Message-ID: <20171130183914.xknl33pxij62hdhp@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144524.23518-1-mhocko@kernel.org>
 <20171130082405.b77eknaiblgmpa4s@dhcp22.suse.cz>
 <1a96e274-a986-12b7-6e47-fc6355cbf637@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a96e274-a986-12b7-6e47-fc6355cbf637@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>

On Thu 30-11-17 10:31:12, John Hubbard wrote:
> On 11/30/2017 12:24 AM, Michal Hocko wrote:
> > Updated version based on feedback from John.
> > ---
> > From ade1eba229b558431581448e7d7838f0e1fe2c49 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 29 Nov 2017 15:32:08 +0100
> > Subject: [PATCH] mmap.2: document new MAP_FIXED_SAFE flag
> > 
> > 4.16+ kernels offer a new MAP_FIXED_SAFE flag which allows the caller to
> > atomicaly probe for a given address range.
> > 
> > [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  man2/mmap.2 | 22 ++++++++++++++++++++++
> >  1 file changed, 22 insertions(+)
> > 
> > diff --git a/man2/mmap.2 b/man2/mmap.2
> > index 385f3bfd5393..923bbb290875 100644
> > --- a/man2/mmap.2
> > +++ b/man2/mmap.2
> > @@ -225,6 +225,22 @@ will fail.
> >  Because requiring a fixed address for a mapping is less portable,
> >  the use of this option is discouraged.
> >  .TP
> > +.BR MAP_FIXED_SAFE " (since Linux 4.16)"
> > +Similar to MAP_FIXED with respect to the
> > +.I
> > +addr
> > +enforcement, but different in that MAP_FIXED_SAFE never clobbers a pre-existing
> > +mapped range. If the requested range would collide with an existing
> > +mapping, then this call fails with
> > +.B EEXIST.
> > +This flag can therefore be used as a way to atomically (with respect to other
> > +threads) attempt to map an address range: one thread will succeed; all others
> > +will report failure. Please note that older kernels which do not recognize this
> > +flag will typically (upon detecting a collision with a pre-existing mapping)
> > +fall back a "non-MAP_FIXED" type of behavior: they will return an address that
> 
> ...and now I've created my own typo: please make that "fall back to a"  (the 
> "to" was missing).
> 
> Sorry about the churn. It turns out that the compiler doesn't catch these. :)

Fixed. I will resubmit after there is more feedback review.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
