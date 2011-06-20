Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D80236B0120
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:59:07 -0400 (EDT)
Received: by vws4 with SMTP id 4so895262vws.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:59:03 -0700 (PDT)
Date: Mon, 20 Jun 2011 13:58:59 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 1/3] mm: completely disable THP by
 transparent_hugepage=never
Message-ID: <20110620175859.GB9697@mgebm.net>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <20110620165844.GA9396@suse.de>
 <4DFF7E3B.1040404@redhat.com>
 <4DFF7F0A.8090604@redhat.com>
 <4DFF8106.8090702@redhat.com>
 <4DFF8327.1090203@redhat.com>
 <4DFF84BB.3050209@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IrhDeMKUP4DT/M7F"
Content-Disposition: inline
In-Reply-To: <4DFF84BB.3050209@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org


--IrhDeMKUP4DT/M7F
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 21 Jun 2011, Cong Wang wrote:

> =E4=BA=8E 2011=E5=B9=B406=E6=9C=8821=E6=97=A5 01:28, Rik van Riel =E5=86=
=99=E9=81=93:
> >On 06/20/2011 01:19 PM, Cong Wang wrote:
> >>=E4=BA=8E 2011=E5=B9=B406=E6=9C=8821=E6=97=A5 01:10, Rik van Riel =E5=
=86=99=E9=81=93:
> >>>On 06/20/2011 01:07 PM, Cong Wang wrote:
> >>>>=E4=BA=8E 2011=E5=B9=B406=E6=9C=8821=E6=97=A5 00:58, Mel Gorman =E5=
=86=99=E9=81=93:
> >>>>>On Tue, Jun 21, 2011 at 12:34:28AM +0800, Amerigo Wang wrote:
> >>>>>>transparent_hugepage=3Dnever should mean to disable THP completely,
> >>>>>>otherwise we don't have a way to disable THP completely.
> >>>>>>The design is broken.
> >>>>>>
> >>>>>
> >>>>>I don't get why it's broken. Why would the user be prevented from
> >>>>>enabling it at runtime?
> >>>>>
> >>>>
> >>>>We need to a way to totally disable it, right? Otherwise, when I
> >>>>configure
> >>>>THP in .config, I always have THP initialized even when I pass "=3Dne=
ver".
> >>>>
> >>>>For me, if you don't provide such way to disable it, it is not flexib=
le.
> >>>>
> >>>>I meet this problem when I try to disable THP in kdump kernel, there =
is
> >>>>no user of THP in kdump kernel, THP is a waste for kdump kernel. This=
 is
> >>>>why I need to find a way to totally disable it.
> >>>
> >>>What you have not explained yet is why having THP
> >>>halfway initialized (but not used, and without a
> >>>khugepaged thread) is a problem at all.
> >>>
> >>>Why is it a problem for you?
> >>
> >>It occupies some memory, memory is valuable in kdump kernel (usually
> >>only 128M). :) Since I am sure no one will use it, why do I still need
> >>to initialize it at all?
> >
> >Lets take a look at how much memory your patches end
> >up saving.
> >
> >By bailing out earlier in hugepage_init, you end up
> >saving 3 sysfs objects, one slab cache and a hash
> >table with 1024 pointers. That's a total of maybe
> >10kB of memory on a 64 bit system.
> >
> >I'm not convinced that a 10kB memory reduction is
> >worth the price of never being able to enable
> >transparent hugepages when a system is booted with
> >THP disabled...
> >
>=20
> Even if it is really 10K, why not save it since it doesn't
> much effort to make this. ;) Not only memory, but also time,
> this could also save a little time to initialize the kernel.
>=20
> For me, the more serious thing is the logic, there is
> no way to totally disable it as long as I have THP in .config
> currently. This is why I said the design is broken.
>=20
> Thanks.
>=20

If memory is this scarce, why not set CONFIG_TRANSPARENT_HUGEPAGE=3Dn and b=
e done
with it?  If the config option is enabled, the admin should be able to turn=
 the
functionality back on if desired.  If you really don't _ever_ want THP then
disable the config.

Eric

--IrhDeMKUP4DT/M7F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN/4pjAAoJEH65iIruGRnNA7MH/3XkhMuDsUIi4Y4IBTehDfkC
rJKtHzfuK5RmKil6pKtnOFnjMPZNgsgKoQgzioQVTUNfQ2XzFwp2sbbF2Xgr4R88
klBKHxHPhFW6qouWusSpyTAswlICAJNvAiao72bIpHoWxnT13+nw9SkPTRsuHZ5H
K7FFpFJwrHeVVgEeAel51GFDDwqDPj3XhG8eQmctGgYZXvJmw3v4g4l+7QiZ+NbX
6Qg/SnCO3lojidbeINtzkzpV9OVx9uH1dWCXuUK5Yi/F1pGB/cb2zXUT63Fsx59O
OoAC7lPig+UloZZxxMC+mMrarXAGZdaWq1ZnrxESp6bt3oMxsOLv+WQrdxziq7Q=
=7RuS
-----END PGP SIGNATURE-----

--IrhDeMKUP4DT/M7F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
