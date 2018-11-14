Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73C406B0010
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:32:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m45-v6so7840499edc.2
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 23:32:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z49si3021071edz.233.2018.11.13.23.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 23:32:31 -0800 (PST)
Date: Wed, 14 Nov 2018 08:32:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] l1tf: drop the swap storage limit restriction when
 l1tf=off
Message-ID: <20181114073229.GC23419@dhcp22.suse.cz>
References: <20181113184910.26697-1-mhocko@kernel.org>
 <nycvar.YFH.7.76.1811132054521.19754@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1811132054521.19754@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 13-11-18 20:56:54, Jiri Kosina wrote:
> On Tue, 13 Nov 2018, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Swap storage is restricted to max_swapfile_size (~16TB on x86_64)
> > whenever the system is deemed affected by L1TF vulnerability. Even
> > though the limit is quite high for most deployments it seems to be
> > too restrictive for deployments which are willing to live with the
> > mitigation disabled.
> > 
> > We have a customer to deploy 8x 6,4TB PCIe/NVMe SSD swap devices
> > which is clearly out of the limit.
> > 
> > Drop the swap restriction when l1tf=off is specified. It also doesn't
> > make much sense to warn about too much memory for the l1tf mitigation
> > when it is forcefully disabled by the administrator.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  Documentation/admin-guide/kernel-parameters.txt | 2 ++
> >  Documentation/admin-guide/l1tf.rst              | 5 ++++-
> >  arch/x86/kernel/cpu/bugs.c                      | 3 ++-
> >  arch/x86/mm/init.c                              | 2 +-
> >  4 files changed, 9 insertions(+), 3 deletions(-)
> > 
> > diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> > index 81d1d5a74728..a54f2bd39e77 100644
> > --- a/Documentation/admin-guide/kernel-parameters.txt
> > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > @@ -2095,6 +2095,8 @@
> >  			off
> >  				Disables hypervisor mitigations and doesn't
> >  				emit any warnings.
> > +				It also drops the swap size and available
> > +				RAM limit restriction.
> 
> Minor nit: I think this should explicitly mention that those two things 
> are related to bare metal mitigation, to avoid any confusion (as otherwise 
> the l1tf cmdline parameter is purely about hypervisor mitigations).

Do you have any specific wording in mind?

It also drops the swap size and available RAM limit restrictions on both
hypervisor and bare metal.

Sounds better?

> With that
> 
> 	Acked-by: Jiri Kosina <jkosina@suse.cz>

Thanks!
-- 
Michal Hocko
SUSE Labs
