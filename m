Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CCC866B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 16:20:06 -0400 (EDT)
Subject: Re: [PATCH 3/7] numa-x86_64-use-generic-percpu-var-numa_node_id-implementation-fix1
In-Reply-To: Your message of "Mon, 24 May 2010 10:41:52 EDT."
             <1274712112.13756.177.camel@useless.americas.hpqcorp.net>
From: Valdis.Kletnieks@vt.edu
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain> <20100503150518.15039.3576.sendpatchset@localhost.localdomain> <20100521160240.b61d3404.akpm@linux-foundation.org> <1274710172.13756.122.camel@useless.americas.hpqcorp.net> <144644.1274710321@localhost>
            <1274712112.13756.177.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1274732394_4243P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 24 May 2010 16:19:54 -0400
Message-ID: <15817.1274732394@localhost>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1274732394_4243P
Content-Type: text/plain; charset=us-ascii

On Mon, 24 May 2010 10:41:52 EDT, Lee Schermerhorn said:
> On Mon, 2010-05-24 at 10:12 -0400, Valdis.Kletnieks@vt.edu wrote:
> > On Mon, 24 May 2010 10:09:32 EDT, Lee Schermerhorn said:
> > > 
> > > You asked about the fix3 patch [offlist] on Wednesday, 19May.  Do you
> > > have that one in your tree?
> >  
> > numa-introduce-numa_mem_id-effective-local-memory-node-id-fix3.patch
> > was in -mmotm0521.
> 
> Right.  But, Andrew needs:
> numa-x86_64-use-generic-percpu-var-numa_node_id-implementation-fix3 --
> i.e., a fix to the 2nd patch of the percpu numa_*_id patch series.

-ENOCAFFIENE ;)

--==_Exmh_1274732394_4243P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL+t9qcC3lWbTT17ARAjj6AJ9IAJBDOiKtQOD/k5u9lQrS2GYERgCeNyd4
9iR8CfKL67AFYE/I17h7w40=
=uhbG
-----END PGP SIGNATURE-----

--==_Exmh_1274732394_4243P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
