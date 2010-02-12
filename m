Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36AF06B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 13:35:14 -0500 (EST)
Subject: Re: [PATCH 06/12] Add /proc trigger for memory compaction
In-Reply-To: Your message of "Fri, 12 Feb 2010 12:00:53 GMT."
             <1265976059-7459-7-git-send-email-mel@csn.ul.ie>
From: Valdis.Kletnieks@vt.edu
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
            <1265976059-7459-7-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1265999680_4070P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 12 Feb 2010 13:34:40 -0500
Message-ID: <7691.1265999680@localhost>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1265999680_4070P
Content-Type: text/plain; charset=us-ascii

On Fri, 12 Feb 2010 12:00:53 GMT, Mel Gorman said:
> This patch adds a proc file /proc/sys/vm/compact_memory. When an arbitrary
> value is written to the file, all zones are compacted. The expected user
> of such a trigger is a job scheduler that prepares the system before the
> target application runs.

Argh. A global trigger in /proc, and a per-node trigger in /sys too.  Can we
get by with just one or the other?  Should the /proc one live in /sys too?


--==_Exmh_1265999680_4070P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLdZ9AcC3lWbTT17ARAuqMAJ9zE7Mlw+qy2dVG4qMLTgAviVaRlgCfTdBT
MFUCALw++Nh/mf9587aU584=
=J6gQ
-----END PGP SIGNATURE-----

--==_Exmh_1265999680_4070P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
