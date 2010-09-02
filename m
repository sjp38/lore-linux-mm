Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 854626B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:48:31 -0400 (EDT)
Received: by wyb36 with SMTP id 36so353271wyb.14
        for <linux-mm@kvack.org>; Thu, 02 Sep 2010 06:48:30 -0700 (PDT)
Date: Thu, 2 Sep 2010 14:48:27 +0100
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 1/2] Add trace points to mmap, munmap, and brk
Message-ID: <20100902134827.GA6957@mgebm.net>
References: <20100721223359.8710.A69D9226@jp.fujitsu.com>
 <20100727110904.GA6519@mgebm.net>
 <20100727201644.2F46.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Content-Disposition: inline
In-Reply-To: <20100727201644.2F46.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 27 Jul 2010, KOSAKI Motohiro wrote:

> > On Wed, 21 Jul 2010, KOSAKI Motohiro wrote:
> >=20
> > > > This patch adds trace points to mmap, munmap, and brk that will rep=
ort
> > > > relevant addresses and sizes before each function exits successfull=
y.
> > > >=20
> > > > Signed-off-by: Eric B Munson <emunson@mgebm.net>
> > >=20
> > > I don't think this is good idea. if you need syscall result, you shou=
ld=20
> > > use syscall tracer. IOW, This tracepoint bring zero information.
> > >=20
> > > Please see perf_event_mmap() usage. Our kernel manage adress space by
> > > vm_area_struct. we need to trace it if we need to know what kernel do=
es.
> > >=20
> > > Thanks.
> >=20
> > The syscall tracer does not give you the address and size of the mmaped=
 areas
> > so this does provide information above simply tracing the enter/exit po=
ints
> > for each call.
>=20
> Why don't you fix this?
>=20
>=20

Sorry for the long delay, the enter/exit routines are not compatible with t=
he
information that these new trace points provides.  When tracing mmap, for
instance, the addr and len arguments can be altered by the function.  If you
use the enter/exit trace points you would not see this as the arguments are
sampled at function entrance and not given again on exit.  Also, the new
trace points are only hit on function success, the exit trace point happens
any time you leave the system call.

I will send out a new series after a rebase.

Thanks,
Eric


--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMf6srAAoJEH65iIruGRnNFNcH+gIEP6H+KA0VeEfHdqpfcQPu
ozIShtWVEOlr77x/d0aWpG2mweyGMD24JCAD8JVYYStUFbUxS0YxOVXBM4jmpmYm
GOBkyDLYwi6iBY0c4k/3VxIakOkEl1yGr7WBCl4To0VbpWxK2JYJLpE8kCr94nh9
Po6lIdOVNK6y42AcpbCm3MtFy3GdBEdz39ZbfrwY9v9/PfzHxUZZzdjmLKEaA7bJ
fhCMgvMmGQU7P4rrzecsC43oqrKUE6beYZjSTTQeq3BgufV4quC3dYzmSycPwVxJ
0NAcLCpMHSago/xGL3A+Ke+IxcL2MFxOfn1G0ybGV9SISo0FWRq393cgi5rCxow=
=zNvZ
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
