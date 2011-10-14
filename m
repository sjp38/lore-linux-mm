Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2A36B0190
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 22:56:23 -0400 (EDT)
Subject: Re: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
In-Reply-To: Your message of "Fri, 14 Oct 2011 00:05:58 +0400."
             <4E9744A6.5010101@parallels.com>
From: Valdis.Kletnieks@vt.edu
References: <1318511382-31051-1-git-send-email-glommer@parallels.com> <20111013.160031.605700447623532119.davem@davemloft.net>
            <4E9744A6.5010101@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1318560959_28908P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 Oct 2011 22:55:59 -0400
Message-ID: <60642.1318560959@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

--==_Exmh_1318560959_28908P
Content-Type: text/plain; charset=us-ascii

On Fri, 14 Oct 2011 00:05:58 +0400, Glauber Costa said:
> On 10/14/2011 12:00 AM, David Miller wrote:

> > Make this evaluate into exactly the same exact code stream we have
> > now when the memory cgroup feature is not in use, which will be the
> > majority of users.
> 
> What exactly do you mean by "not in use" ? Not compiled in or not 
> actively being exercised ? If you mean the later, I appreciate tips on 
> how to achieve it.
> 
> Also, I kind of dispute the affirmation that !cgroup will encompass
> the majority of users, since cgroups is being enabled by default by
> most vendors. All systemd based systems use it extensively, for instance.

Yes, systemd requires a kernel that includes cgroups.  However, systemd does
*not* require the memory cgroup feature.  As a practical matter, if your patch
doesn't generate equivalent code for the "have cgroups, but no memory cgroup"
situation, it's a non-starter.

--==_Exmh_1318560959_28908P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOl6S/cC3lWbTT17ARArxnAKDanOuIMQXHrs/wd4CYgmiG8QsllQCeN/MT
xx+W0iVP/IssCSI12NSp7yI=
=czOf
-----END PGP SIGNATURE-----

--==_Exmh_1318560959_28908P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
