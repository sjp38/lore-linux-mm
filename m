Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A4C1F6B0209
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 14:23:01 -0400 (EDT)
Subject: Re: [PATCH 1/4] vmscan: simplify shrink_inactive_list()
In-Reply-To: Your message of "Thu, 15 Apr 2010 14:15:33 BST."
             <20100415131532.GD10966@csn.ul.ie>
From: Valdis.Kletnieks@vt.edu
References: <20100415085420.GT2493@dastard> <20100415185310.D1A1.A69D9226@jp.fujitsu.com> <20100415192140.D1A4.A69D9226@jp.fujitsu.com>
            <20100415131532.GD10966@csn.ul.ie>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1271355721_4032P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 14:22:01 -0400
Message-ID: <16363.1271355721@localhost>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1271355721_4032P
Content-Type: text/plain; charset=us-ascii

On Thu, 15 Apr 2010 14:15:33 BST, Mel Gorman said:

> Yep. I modified bloat-o-meter to work with stacks (imaginatively calling it
> stack-o-meter) and got the following. The prereq patches are from
> earlier in the thread with the subjects

Think that's a script worth having in-tree?

--==_Exmh_1271355721_4032P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLx1lJcC3lWbTT17ARAqyGAKC1f3e2OAbaTieb6RAjylZZcPhsegCgs3Lo
UCfgZZyeWUYEmBR3Lfn73d4=
=mkPa
-----END PGP SIGNATURE-----

--==_Exmh_1271355721_4032P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
