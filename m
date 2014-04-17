Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5E09A6B0073
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 22:38:48 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so101182eek.1
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 19:38:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si32921493eei.235.2014.04.16.19.38.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 19:38:46 -0700 (PDT)
Date: Thu, 17 Apr 2014 12:38:37 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
Message-ID: <20140417123837.5987e5e9@notabene.brown>
In-Reply-To: <20140416.090002.2186526865564557549.davem@davemloft.net>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.96000.stgit@notabene.brown>
	<1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140416.090002.2186526865564557549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/SSVtvNA+Qn7U/.GV8.0daYz"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: eric.dumazet@gmail.com, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org

--Sig_/SSVtvNA+Qn7U/.GV8.0daYz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 09:00:02 -0400 (EDT) David Miller <davem@davemloft.net>
wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 15 Apr 2014 22:13:46 -0700
>=20
> > For applications handling millions of sockets, this makes a difference.
>=20
> Indeed, this really is not acceptable.

As you say...
I've just discovered that I can get rid of the lockdep message (and hence
presumably the deadlock risk) with a well placed:

		newsock->sk->sk_allocation =3D GFP_NOFS;

which surprised me as it seemed to be an explicit GFP_KERNEL allocation that
was mentioned in the lockdep trace.  Obviously these traces require quite
some sophistication to understand.

So - thanks for the feedback, patch can be ignored.

Thanks,
NeilBrown

--Sig_/SSVtvNA+Qn7U/.GV8.0daYz
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU08+rTnsnt1WYoG5AQLRZhAAw2OqHGStjcH4tCI4w3eDMVb87MK1AVtQ
U3pUF/WbzPSl0yhxDaa3vIg6L2ogkASESK6Oiiu8PZbG3TunCNwq63XXTKvE6EIY
nABc2yOb9u/cixXtIuMC9E8ydnZa/dEkIyFY9oMXBjuOwb3L/ugKFm0upzBUVokw
VtyZs8rl9s9IwgvuErpFbDR3ZxEk0VaMdREFwGCpkUD6DjknMTpGdaUelPxe+DEd
Ffy6B7fjrkdG/8B4vYZKlW2c5on1lLqc+hgY24LrLUpLxHwu4HCuIrAuhzILDex/
X5hZbQQhj2reLB8rsqJWOjmKn19/y8EbapUwa6BUMkSVHDCf0voCUjkHI8dOYcvM
TnrmEzJS3Ym/x5rbenUCr2hEOEbZ80UEcMbdbrVm3rhPoMDtSifdtU2LEKro8oCk
GPoOR3fYSLyxXNGQTlGiG3vSuSAIxF8tznBLnuCPIAPXK8LtXIn3oIOxNsN1J/LK
TxZJsdA+I9YmV5uIn7cJarNYKdXvhR6x0YPoxUFzQZkngChosN3ZkGOHQeG2moyA
JewuEtWT5Z1n1as19big3XukdBNnhJ/B11DpyI3TlfhIYN0mROFEAQkvXuOYYO+o
CqkHfQp765IaTt0WOiVFu9bibhdxWwt1jwfasn1TE9LtvVlwlUlbPVL/8NrMXnOa
Nkz7UZ1IxWU=
=WfY/
-----END PGP SIGNATURE-----

--Sig_/SSVtvNA+Qn7U/.GV8.0daYz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
