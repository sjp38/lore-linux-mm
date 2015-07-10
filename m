Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 82AD96B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 12:20:08 -0400 (EDT)
Received: by qgef3 with SMTP id f3so81663586qge.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 09:20:08 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id d133si1167743qhc.121.2015.07.10.09.19.49
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 09:19:54 -0700 (PDT)
Date: Fri, 10 Jul 2015 12:19:48 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add mlock
 flags to enable it
Message-ID: <20150710161948.GF4669@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
 <1436288623-13007-4-git-send-email-emunson@akamai.com>
 <20150708132351.61c13db6@lwn.net>
 <20150708203456.GC4669@akamai.com>
 <20150708151750.75e65859@lwn.net>
 <20150709184635.GE4669@akamai.com>
 <20150710101118.5d04d627@lwn.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="B0nZA57HJSoPbsHY"
Content-Disposition: inline
In-Reply-To: <20150710101118.5d04d627@lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--B0nZA57HJSoPbsHY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Jul 2015, Jonathan Corbet wrote:

> On Thu, 9 Jul 2015 14:46:35 -0400
> Eric B Munson <emunson@akamai.com> wrote:
>=20
> > > One other question...if I call mlock2(MLOCK_ONFAULT) on a range that
> > > already has resident pages, I believe that those pages will not be lo=
cked
> > > until they are reclaimed and faulted back in again, right?  I suspect=
 that
> > > could be surprising to users. =20
> >=20
> > That is the case.  I am looking into what it would take to find only the
> > present pages in a range and lock them, if that is the behavior that is
> > preferred I can include it in the updated series.
>=20
> For whatever my $0.02 is worth, I think that should be done.  Otherwise
> the mlock2() interface is essentially nondeterministic; you'll never
> really know if a specific page is locked or not.
>=20
> Thanks,
>=20
> jon

Okay, I likely won't have the new set out today then.  This change is
more invasive.  IIUC, I need an equivalent to __get_user_page() skips
pages which are not present instead of faulting in and the call chain to
get to it.  Unless there is an easier way that I am missing.

Eric

--B0nZA57HJSoPbsHY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVn/CkAAoJELbVsDOpoOa9fc8QAIYPJoEtJnOGLcp6XvlbR0qD
EHm5hYg6euX6IzBeU/n1N4DZEv/6AHxxj33+oWf/0SvA7JpsvIZeCsy58KoiZzkO
1z8xIe4ErMaaA4rb8O096V176BNouwx50PXJdPazalmkeWT6KFmgcLYhVLGJAFkW
m5em8mli28pJiSRilOCcAffiHvt8+ThcCMqLqAKlQwz2AlvIcJQR8fBp59rmRE6r
c4fYHulmiZHSsLbmvs3XoC1ChdgjUtloN7VEeDDs2Q9V3De0Vw7AzInIbW+7zwaL
B+FnQmRpDvTcthu64eFo0cB+GBUfXSCIt+1Nugzl+Zir6N6hGPJemoEX2XzzNDnO
L3M0uDFGR2RXyLLTfLsTFQfCLMpxtSz8QFM9/yDzQVntENCfEAainCWjaJLxSLsV
yBPZxXiEdLgxTCFoo5hX/RL2tmge3x3WNnqReHEP9dt0r4UvxXxGOnlQk2I8TUgg
fINo4V8a92DG4McWbhzqKofewDYrvY+rJ3I8jW2QC4QttTO8wJwycAurfhe0pv1M
Jk9Exv6mn9JmQ7SxYQqOqz4nu92x6WsEbSaT0Syt0IFJYj4xcVUup/npgJKB9oDn
7RXjXvHTRAUm4D+6PPW2ECmwHMWIcs/WpHoiKt3GrP3jkh1rqpXImXOagRpv/4kf
+6n7EoyLk21P33MtY3g6
=Tkn9
-----END PGP SIGNATURE-----

--B0nZA57HJSoPbsHY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
