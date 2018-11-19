Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFDFF6B1A3E
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:51:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id n32-v6so15502118edc.17
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:51:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si8725616edx.32.2018.11.19.05.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 05:51:51 -0800 (PST)
Date: Mon, 19 Nov 2018 14:51:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] l1tf: drop the swap storage limit restriction when
 l1tf=off
Message-ID: <20181119135149.GN22247@dhcp22.suse.cz>
References: <20181113184910.26697-1-mhocko@kernel.org>
 <nycvar.YFH.7.76.1811132054521.19754@cbobk.fhfr.pm>
 <20181114073229.GC23419@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1811191436140.21108@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1811191436140.21108@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 19-11-18 14:36:32, Jiri Kosina wrote:
> On Wed, 14 Nov 2018, Michal Hocko wrote:
> 
> > > > +				It also drops the swap size and available
> > > > +				RAM limit restriction.
> > > 
> > > Minor nit: I think this should explicitly mention that those two things 
> > > are related to bare metal mitigation, to avoid any confusion (as otherwise 
> > > the l1tf cmdline parameter is purely about hypervisor mitigations).
> > 
> > Do you have any specific wording in mind?
> > 
> > It also drops the swap size and available RAM limit restrictions on both
> > hypervisor and bare metal.
> > 
> > Sounds better?
> > 
> > > With that
> > > 
> > > 	Acked-by: Jiri Kosina <jkosina@suse.cz>
> > 
> > Thanks!
> 
> Yes, I think that makes it absolutely clear. Thanks,

OK. Here is the incremental diff on top of the patch. I will fold and
repost later this week. I assume people are still catching up after LPC
and I do not want to spam them even more.

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index a54f2bd39e77..c5aa4b4a797d 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2096,7 +2096,8 @@
 				Disables hypervisor mitigations and doesn't
 				emit any warnings.
 				It also drops the swap size and available
-				RAM limit restriction.
+				RAM limit restriction on both hypervisor and
+				bare metal.
 
 			Default is 'flush'.
 
diff --git a/Documentation/admin-guide/l1tf.rst b/Documentation/admin-guide/l1tf.rst
index b00464a9c09c..2e65e6cb033e 100644
--- a/Documentation/admin-guide/l1tf.rst
+++ b/Documentation/admin-guide/l1tf.rst
@@ -405,7 +405,8 @@ The kernel command line allows to control the L1TF mitigations at boot
 
   off		Disables hypervisor mitigations and doesn't emit any
 		warnings.
-		It also drops the swap size and available RAM limit restrictions.
+		It also drops the swap size and available RAM limit restrictions
+                on both hypervisor and bare metal.
 
   ============  =============================================================
 
-- 
Michal Hocko
SUSE Labs
