Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 730319000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 11:06:27 -0400 (EDT)
Date: Mon, 3 Oct 2011 11:06:20 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 0/9] V2: idle page tracking / working set estimation
Message-ID: <20111003150619.GA12778@mgebm.net>
References: <1317170947-17074-1-git-send-email-walken@google.com>
 <20110929164319.GA3509@mgebm.net>
 <CANN689H1G-USQYQrOTb47Hrc7KMjLdxkppYCDKsTUy5WhuRs7w@mail.gmail.com>
 <4186d5662b3fb21af1b45f8a335414d3@mgebm.net>
 <20110930181914.GA17817@mgebm.net>
 <CANN689EN8KsBZj_9cABjJoZNou_UegZ8uqB4Lx=uM-B_4aCd7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Content-Disposition: inline
In-Reply-To: <CANN689EN8KsBZj_9cABjJoZNou_UegZ8uqB4Lx=uM-B_4aCd7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 30 Sep 2011, Michel Lespinasse wrote:

> On Fri, Sep 30, 2011 at 11:19 AM, Eric B Munson <emunson@mgebm.net> wrote:
> > I am able to recreate on a second desktop I have here (same model CPU b=
ut a
> > different MB so I am fairly sure it isn't dying hardware). =A0It looks =
to me like
> > a CPU softlocks and it stalls the process active there, so most recentl=
y that
> > was XOrg. =A0The machine lets me login via ssh for a few minutes, but t=
hings like
> > ps and cat or /proc files will start to work and give some output but h=
ang.
> > I cannot call reboot, nor can I sync the fs and reboot via SysRq. =A0My=
 next step
> > is to setup a netconsole to see if anything comes out in the syslog tha=
t I
> > cannot see.
>=20
> I haven't had time to try & reproduce locally yet (apologies - things
> have been coming up at me).
>=20
> But a prime suspect would be a bad interaction with
> CONFIG_MEMORY_HOTPLUG, as Kamezama remarked in his reply to patch 4. I
> think this could be the most likely cause of what you're observing.
>=20

CONFIG_MEMORY_HOTPLUG seems to be the responsible party here, I disabled it=
 in
my config and have been able to build 6 kernels straight without a hang.

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOic9rAAoJEH65iIruGRnNOM8H/RM6ZqrSNl7ImpPexVB6Tv+a
TYYY01tChp8Oci2tMPj1aKHLH/uVdxZyiT22XmnveudQxOETQTgKRzNFdcO9DskS
s8ZlOkTyg3CJ4g7BpDBNtwHisq1ePL5UfGtTH5cEz5Jc6UEvxRrjKO183r/Fo1Wt
ot4LEJ/BTDJAj438QdIMvZusvFz0UvjsBnWWhQhqT5XID3e57DavtpZGlOZCU1LZ
h0j60XnPd0fifxO3mthVsczHwC+LQJ9MIKtH/RWX4gDdknyWh0+lrjnMWM19XkDN
ew1Vsrxmfsz9d0nlyY6FqwvmVoFuya17HK28wz3jXrT/M7+gBRrTDSp0kz0a4Ro=
=NErA
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
