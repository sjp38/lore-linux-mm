Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0EF900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 10:27:12 -0400 (EDT)
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
In-Reply-To: Your message of "Thu, 18 Aug 2011 11:38:00 +0200."
             <20110818093800.GA2268@redhat.com>
From: Valdis.Kletnieks@vt.edu
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
            <20110818093800.GA2268@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1313677618_2646P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Aug 2011 10:26:58 -0400
Message-ID: <96939.1313677618@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--==_Exmh_1313677618_2646P
Content-Type: text/plain; charset=us-ascii

On Thu, 18 Aug 2011 11:38:00 +0200, Johannes Weiner said:

> Note that on non-x86, these operations themselves actually disable and
> reenable preemption each time, so you trade a pair of add and sub on
> x86
> 
> -	preempt_disable()
> 	__this_cpu_xxx()
> 	__this_cpu_yyy()
> -	preempt_enable()
> 
> with
> 
> 	preempt_disable()
> 	__this_cpu_xxx()
> +	preempt_enable()
> +	preempt_disable()
> 	__this_cpu_yyy()
> 	preempt_enable()
> 
> everywhere else.

That would be an unexpected race condition on non-x86, if you expected _xxx and
_yyy to be done together without a preempt between them. Would take mere
mortals forever to figure that one out. :)


--==_Exmh_1313677618_2646P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOTSEycC3lWbTT17ARAu4ZAJwJY9zOTyoMHoaP1AEBeEbLV7ts/gCfdoVm
jvD0MeR2VgZciqe/gYUOqxE=
=TMnA
-----END PGP SIGNATURE-----

--==_Exmh_1313677618_2646P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
