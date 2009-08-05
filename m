Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A08B56B004D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 10:54:39 -0400 (EDT)
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
In-Reply-To: Your message of "Tue, 04 Aug 2009 21:57:17 +0200."
             <20090804195717.GA5998@elte.hu>
From: Valdis.Kletnieks@vt.edu
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
            <20090804195717.GA5998@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1249484030_3824P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 05 Aug 2009 10:53:50 -0400
Message-ID: <16246.1249484030@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mel@csn.ul.ie>, Larry Woodman <lwoodman@redhat.com>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1249484030_3824P
Content-Type: text/plain; charset=us-ascii

On Tue, 04 Aug 2009 21:57:17 +0200, Ingo Molnar said:

> Let me demonstrate these features in action (i've applied the 
> patches for testing to -tip):
> 
> First, discovery/enumeration of available counters can be done via 
> 'perf list':

Woo hoo! A perf cheat sheet! perf's usability just went up 110%, at least
for me.

Thanks for the clear demo. ;)

--==_Exmh_1249484030_3824P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFKeZz+cC3lWbTT17ARAthwAJ9iV+frrscEnfUCi6AepglcAzXzgACg3lLF
Hih3Fs/miSAqZpcg8z7KSzo=
=ciaC
-----END PGP SIGNATURE-----

--==_Exmh_1249484030_3824P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
