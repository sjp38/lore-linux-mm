Date: Wed, 8 Nov 2006 13:47:44 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] Fix sys_move_pages when a NULL node list is passed.
Message-Id: <20061108134744.ffc504ea.sfr@canb.auug.org.au>
In-Reply-To: <20061108111341.748d034a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061103144243.4601ba76.sfr@canb.auug.org.au>
	<20061108105648.4a149cca.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0611071800250.7749@schroedinger.engr.sgi.com>
	<20061108111341.748d034a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__8_Nov_2006_13_47_44_+1100_QfM8F8A/ohkeMlV+"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

--Signature=_Wed__8_Nov_2006_13_47_44_+1100_QfM8F8A/ohkeMlV+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Wed, 8 Nov 2006 11:13:41 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Ah.. I'm mentioning to this.
> ==
> +			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
> ==
> Sorry for my bad cut & paste.
>
> It seems that this 0 will be passed to alloc_pages_node().
> alloc_pages_node() doesn't check whether a node is online or not before using
> NODE_DATA().

Actually, it won't.  If you do that assignment, then the nodes parameter
was NULL and you will only call do_pages_stat() and so never call
alloc_pages_node().

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__8_Nov_2006_13_47_44_+1100_QfM8F8A/ohkeMlV+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFUUVQFdBgD/zoJvwRAlkAAJ9xVpVPGVxzgTBXK43YZT06LIAuRACgg9U8
aG8yonkAKDqcPmYKXVM5m2I=
=FE0y
-----END PGP SIGNATURE-----

--Signature=_Wed__8_Nov_2006_13_47_44_+1100_QfM8F8A/ohkeMlV+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
