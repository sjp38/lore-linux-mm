Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E5E246B01EE
	for <linux-mm@kvack.org>; Wed, 12 May 2010 15:28:07 -0400 (EDT)
Subject: Re: [PATCH 6/8] numa: slab: use numa_mem_id() for slab local memory node
In-Reply-To: Your message of "Wed, 12 May 2010 15:11:43 EDT."
             <1273691503.6985.142.camel@useless.americas.hpqcorp.net>
From: Valdis.Kletnieks@vt.edu
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain> <20100415173030.8801.84836.sendpatchset@localhost.localdomain> <20100512114900.a12c4b35.akpm@linux-foundation.org>
            <1273691503.6985.142.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1273692351_3904P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 12 May 2010 15:25:51 -0400
Message-ID: <4170.1273692351@localhost>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1273692351_3904P
Content-Type: text/plain; charset=us-ascii

On Wed, 12 May 2010 15:11:43 EDT, Lee Schermerhorn said:
> On Wed, 2010-05-12 at 11:49 -0700, Andrew Morton wrote:
> > I have a note here that this patch "breaks slab.c".  But I don't recall what
> > the problem was and I don't see a fix against this patch in your recently-sent
> > fixup series?
> 
> Is that Valdis Kletnieks' issue?  That was an i386 build.  Happened
> because the earlier patches didn't properly default numa_mem_id() to
> numa_node_id() for the i386 build.  The rework to those patches has
> fixed that.   I have successfully built mmotm with the rework patches
> for i386+!NUMA.  Valdis tested the series and confirmed that it fixed
> the problem.

I thought the problem was common to both i386 and X86_64 non-NUMA (which is
where I hit the problem). In any case, builds OK for me now.

--==_Exmh_1273692351_3904P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL6wC/cC3lWbTT17ARAhAZAJ0Xr2Psa71AVoIG2Y3OnnggsC3CTwCg9X8e
X57rbf1qSyZEJI6d9Jl0OuY=
=kSyj
-----END PGP SIGNATURE-----

--==_Exmh_1273692351_3904P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
