Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC1976B1A06
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:36:36 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a18so20468343pga.16
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:36:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b17si32894980pgk.581.2018.11.19.05.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 05:36:35 -0800 (PST)
Date: Mon, 19 Nov 2018 14:36:32 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] l1tf: drop the swap storage limit restriction when
 l1tf=off
In-Reply-To: <20181114073229.GC23419@dhcp22.suse.cz>
Message-ID: <nycvar.YFH.7.76.1811191436140.21108@cbobk.fhfr.pm>
References: <20181113184910.26697-1-mhocko@kernel.org> <nycvar.YFH.7.76.1811132054521.19754@cbobk.fhfr.pm> <20181114073229.GC23419@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 14 Nov 2018, Michal Hocko wrote:

> > > +				It also drops the swap size and available
> > > +				RAM limit restriction.
> > 
> > Minor nit: I think this should explicitly mention that those two things 
> > are related to bare metal mitigation, to avoid any confusion (as otherwise 
> > the l1tf cmdline parameter is purely about hypervisor mitigations).
> 
> Do you have any specific wording in mind?
> 
> It also drops the swap size and available RAM limit restrictions on both
> hypervisor and bare metal.
> 
> Sounds better?
> 
> > With that
> > 
> > 	Acked-by: Jiri Kosina <jkosina@suse.cz>
> 
> Thanks!

Yes, I think that makes it absolutely clear. Thanks,

-- 
Jiri Kosina
SUSE Labs
