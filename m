Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 890A66B00A2
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 00:26:11 -0400 (EDT)
Subject: Re: [resend][PATCH v2] mlock() doesn't wait to finish lru_add_drain_all()
In-Reply-To: Your message of "Tue, 13 Oct 2009 10:17:48 +0900."
             <20091013090347.C752.A69D9226@jp.fujitsu.com>
From: Valdis.Kletnieks@vt.edu
References: <20091009111709.1291.A69D9226@jp.fujitsu.com> <20091012165747.97f5bd87.akpm@linux-foundation.org>
            <20091013090347.C752.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1255407959_3557P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Oct 2009 00:25:59 -0400
Message-ID: <15231.1255407959@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Oleg Nesterov <onestero@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1255407959_3557P
Content-Type: text/plain; charset=us-ascii

On Tue, 13 Oct 2009 10:17:48 +0900, KOSAKI Motohiro said:

> > How did you work out why the lru_add_drain_all() is present in
> > sys_mlock() anyway?  Neither the code nor the original changelog tell
> > us.  Who do I thwap for that?  Nick and his reviewers.  Sigh.
> 
> [Umm, My dictionaly don't tell me the meaning of "thwap".  An meaning of
> an imitative word strongly depend on culture. Thus, I probably
> misunderstand this paragraph.]

http://ars.userfriendly.org/cartoons/?id=20030210&mode=classic

(biff, thwap, it's all the same - the sound of a cluebat impacting somebody ;)

--==_Exmh_1255407959_3557P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFK1AFXcC3lWbTT17ARAoeQAKCYdCjq/kfHDCI2Rv34Pm9qNPVH7gCfXh0d
VHh8gS/i1yh4u1ksCJvnSnY=
=7xJN
-----END PGP SIGNATURE-----

--==_Exmh_1255407959_3557P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
