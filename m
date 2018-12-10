Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 701C88E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 15:03:27 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so8088455pgv.23
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 12:03:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l185si10149091pgd.253.2018.12.10.12.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 12:03:26 -0800 (PST)
Date: Mon, 10 Dec 2018 21:03:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] l1tf: drop the swap storage limit restriction when
 l1tf=off
Message-ID: <20181210200320.GX1286@dhcp22.suse.cz>
References: <20181113184910.26697-1-mhocko@kernel.org>
 <nycvar.YFH.7.76.1811132054521.19754@cbobk.fhfr.pm>
 <20181114073229.GC23419@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1811191436140.21108@cbobk.fhfr.pm>
 <20181119135149.GN22247@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1812092145510.17216@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1812092145510.17216@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Jiri Kosina <jikos@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun 09-12-18 21:46:57, Jiri Kosina wrote:
> On Mon, 19 Nov 2018, Michal Hocko wrote:
> 
> > > > > > +				It also drops the swap size and available
> > > > > > +				RAM limit restriction.
> > > > > 
> > > > > Minor nit: I think this should explicitly mention that those two things 
> > > > > are related to bare metal mitigation, to avoid any confusion (as otherwise 
> > > > > the l1tf cmdline parameter is purely about hypervisor mitigations).
> > > > 
> > > > Do you have any specific wording in mind?
> > > > 
> > > > It also drops the swap size and available RAM limit restrictions on both
> > > > hypervisor and bare metal.
> > > > 
> > > > Sounds better?
> > > > 
> > > > > With that
> > > > > 
> > > > > 	Acked-by: Jiri Kosina <jkosina@suse.cz>
> > > > 
> > > > Thanks!
> > > 
> > > Yes, I think that makes it absolutely clear. Thanks,
> > 
> > OK. Here is the incremental diff on top of the patch. I will fold and
> > repost later this week. I assume people are still catching up after LPC
> > and I do not want to spam them even more.
> 
> Is this queued anywhere in the meantime please?

Not yet. Thanks for the reminder. It completely fall of my radar.

Thomas, do you want me to resubmit or there are some other changes you
would like to see?
-- 
Michal Hocko
SUSE Labs
