Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3936B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 21:52:57 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so15204768pab.21
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 18:52:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id c2si25037176pbo.188.2014.01.02.18.52.55
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 18:52:55 -0800 (PST)
Date: Thu, 2 Jan 2014 21:33:46 -0500
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: Re: [RFC PATCHv3 01/11] mce: acpi/apei: Use get_vm_area directly
Message-ID: <20140103023346.GC1913@gchen.bj.intel.com>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
 <1388699609-18214-2-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4ZLFUWh1odzi/v6L"
Content-Disposition: inline
In-Reply-To: <1388699609-18214-2-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org


--4ZLFUWh1odzi/v6L
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 02, 2014 at 01:53:19PM -0800, Laura Abbott wrote:
> There's no need to use VMALLOC_START and VMALLOC_END with
> __get_vm_area when get_vm_area does the exact same thing.
> Convert over.
>=20
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Ack-by: Chen, Gong <gong.chen@linux.intel.com>

--4ZLFUWh1odzi/v6L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSxiGJAAoJEI01n1+kOSLHHnMQAJUYxbX5bO/DCVMasvDbRMjl
Asjtkqf8Dzn4l7AN0InmuPUXLvRSDVMwUdtJYIyYr62G9JiySIpLeq05wloUfNnv
9quueR51yCA0y+z18/ImcXD+LBt8YVxwo4oaXNByCy+eq7tWvZ0hXe76g5gUL+f5
053GWAGlxtHAtKm4JCLBx/IxXmC8Y2FleIhacOEv3ernN4FjBbziudy5wSVhy5hh
NT40Scj1MxVXR7afDYzEodLbVpx+e7Voxa+vuNBVoIaT9GCt6FF1DrTOIStSq5CA
29QI8CsP5NCkpEqdpzpnb+EzfFFmwIt3q1XCtrfn3oQVaUARh9uhBib1cV2zygzo
IDmWYzQa97wqGZyydKLXTEPoWO63WRQrIKdcZGLS5rS+2NurgyrsCKBqHWkRY41t
UblgPJWLfD0XBqplpTfq1WvO9bauneZJ9J++4/HOInAxUYRc4QfBmxdE3ipSWOBM
EI8NuqhVlvX9LC6uD49F7i+ugT3l/OHaX3laYBj9xMmbPmdhT4hVVxjfPCI3Eh7e
Be4fI4xGdKK4xWYFL0ulhwktcPeFlAkFe08bhvRYN10YrYQcQ2E0UeLm+qA96Feu
pOJWOhVffl5iCrPS1dLhyOY5AtIS7nDs4Kgd489UT/a4x2QIx0+pRAHoMoY5Kg85
yegIXOfeMuSQLN09+wvq
=xoax
-----END PGP SIGNATURE-----

--4ZLFUWh1odzi/v6L--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
