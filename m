Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9028E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 15:47:00 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so4364190edb.22
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 12:47:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t26si1507167eds.246.2018.12.09.12.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Dec 2018 12:46:59 -0800 (PST)
Date: Sun, 9 Dec 2018 21:46:57 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] l1tf: drop the swap storage limit restriction when
 l1tf=off
In-Reply-To: <20181119135149.GN22247@dhcp22.suse.cz>
Message-ID: <nycvar.YFH.7.76.1812092145510.17216@cbobk.fhfr.pm>
References: <20181113184910.26697-1-mhocko@kernel.org> <nycvar.YFH.7.76.1811132054521.19754@cbobk.fhfr.pm> <20181114073229.GC23419@dhcp22.suse.cz> <nycvar.YFH.7.76.1811191436140.21108@cbobk.fhfr.pm> <20181119135149.GN22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 19 Nov 2018, Michal Hocko wrote:

> > > > > +				It also drops the swap size and available
> > > > > +				RAM limit restriction.
> > > > 
> > > > Minor nit: I think this should explicitly mention that those two things 
> > > > are related to bare metal mitigation, to avoid any confusion (as otherwise 
> > > > the l1tf cmdline parameter is purely about hypervisor mitigations).
> > > 
> > > Do you have any specific wording in mind?
> > > 
> > > It also drops the swap size and available RAM limit restrictions on both
> > > hypervisor and bare metal.
> > > 
> > > Sounds better?
> > > 
> > > > With that
> > > > 
> > > > 	Acked-by: Jiri Kosina <jkosina@suse.cz>
> > > 
> > > Thanks!
> > 
> > Yes, I think that makes it absolutely clear. Thanks,
> 
> OK. Here is the incremental diff on top of the patch. I will fold and
> repost later this week. I assume people are still catching up after LPC
> and I do not want to spam them even more.

Is this queued anywhere in the meantime please?

Thanks,

-- 
Jiri Kosina
SUSE Labs
