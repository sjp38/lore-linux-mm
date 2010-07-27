Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B1EFC600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 07:09:10 -0400 (EDT)
Received: by wyg36 with SMTP id 36so3388051wyg.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:09:08 -0700 (PDT)
Date: Tue, 27 Jul 2010 12:09:04 +0100
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 1/2] Add trace points to mmap, munmap, and brk
Message-ID: <20100727110904.GA6519@mgebm.net>
References: <cover.1279558781.git.emunson@mgebm.net>
 <f6a595dfac141397dcac8c29475be73d10f5248c.1279558781.git.emunson@mgebm.net>
 <20100721223359.8710.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Content-Disposition: inline
In-Reply-To: <20100721223359.8710.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 21 Jul 2010, KOSAKI Motohiro wrote:

> > This patch adds trace points to mmap, munmap, and brk that will report
> > relevant addresses and sizes before each function exits successfully.
> >=20
> > Signed-off-by: Eric B Munson <emunson@mgebm.net>
>=20
> I don't think this is good idea. if you need syscall result, you should=
=20
> use syscall tracer. IOW, This tracepoint bring zero information.
>=20
> Please see perf_event_mmap() usage. Our kernel manage adress space by
> vm_area_struct. we need to trace it if we need to know what kernel does.
>=20
> Thanks.

The syscall tracer does not give you the address and size of the mmaped are=
as
so this does provide information above simply tracing the enter/exit points
for each call.

perf_event_mmap does provide the information for mmap calls.  Originally I =
sent
a patch to add a trace point to munmap and Peter Z asked for corresponding =
points
in the mmap family.  If the consensus is that the trace point in munmap is =
the
only one that should be added I can resend that patch.

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMTr5QAAoJEH65iIruGRnNmSgH/12U99EVo3kI42/mdzDVQsN7
HeA54RKgS49LefEaGRJrL5YcySn+OoEcKJHbqo5ci9bZ+E/NNAsQ3FLrJbKHkXSP
fg6+8rGUmjXCxKRhV90A4kdV+njkv6zC50t5kwf++YVfAYKnlfoqRI8qMaGpkx3z
hOsCbbYrIl1An6huj2RNf4JtpMyX72E4gEyt4SR7tYWlY3QvX+qKYyauFwSZLW8j
MFh2IKZdPtn5mDJl+Lgtwx2485hWxte1sBlVKYYRcZUFuU0uirTedCjTLrZr6AHL
F+0wliiphdh4GfuFEZwtBp8zPy77POk9RMUBtP86UkNQYsx7sKa/B3hm2/+c6D0=
=+aKZ
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
