Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 415D16B007E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 08:28:45 -0500 (EST)
Date: Tue, 28 Feb 2012 16:30:38 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/2] vmalloc: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
Message-ID: <20120228133037.GG2817@mwanda>
References: <1330421640-5137-1-git-send-email-dmitry.antipov@linaro.org>
 <20120228094415.GA2868@mwanda>
 <4F4CC19D.9040608@linaro.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bpVaumkpfGNUagdU"
Content-Disposition: inline
In-Reply-To: <4F4CC19D.9040608@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Antipov <dmitry.antipov@linaro.org>
Cc: Rusty Russell <rusty.russell@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-dev@lists.linaro.org, patches@linaro.org


--bpVaumkpfGNUagdU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 28, 2012 at 03:59:25PM +0400, Dmitry Antipov wrote:
> On 02/28/2012 01:44 PM, Dan Carpenter wrote:
> >On Tue, Feb 28, 2012 at 01:33:59PM +0400, Dmitry Antipov wrote:
> >>  - Fix vmap() to return ZERO_SIZE_PTR if 0 pages are requested;
> >>  - fix __vmalloc_node_range() to return ZERO_SIZE_PTR if 0 bytes
> >>    are requested;
> >>  - fix __vunmap() to check passed pointer with ZERO_OR_NULL_PTR.
> >>
> >
> >Why?
>=20
> 1) it was requested by the subsystem (co?)maintainer, see http://lkml.org=
/lkml/2012/1/27/475;
> 2) this looks to be a convenient way to trace/debug zero-size allocation =
errors (although
>    I don't advocate it as a best way).

Could you include that in the changelog when the final version is
ready?

regards,
dan carpenter

--bpVaumkpfGNUagdU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPTNb9AAoJEOnZkXI/YHqRrqcP/jaoljPhqho4mWZ4LW0hUsec
8t25uxiUsI/POB5AgBC250hQCLSQrLWJM/piQhKdV6cIMOtccBaiQdoUHVGVKpmT
xe7EopnUnwn9OC45sY7iwGmLJ1BCw+1PJ4bpfFfJuxXs2+rMbToeR4sfiWt/T19d
VA7N3sORxDCRgGT77VpCW+XG8xguvObQ4WhBtHOKxVfANxYlOwvC54vxzfpF1txo
//RwLAXAC4hADMaeQHuneIT5NnI68t2O4QYjBb3OZI5q/uvyBe/dOnKdJZqgSPxz
v6f0TCLY/Pueg/0+e0/ZB/4zUyIWOmt0oU8nAThZvdUYUtpGwjT8AZRoX8I7nJaP
KOjWqsy1Z1FYnP7OnDMXkmQoPJqsR1gmtfhTXpdB5i/UZ6ofClnTuxsZ+/epAr1X
S7fwIxCXGJuIfwxwb3+Y87dCzpV2KDjKvMPdlP6xwJ2KdHfB1MkuJAf4yCJfvFFf
mBIPmnToOJmZJJLMzqHvRwhDX/bQSnAeFTVcEbCcaDnh3ERPqutqFeR5ugDth99r
54SYTX6+iLAQg6fIOP34RzIrZ0bNlvV8V2DQxzZRTik0HjLK27eYQGeZMiMvkZMW
6H9W0aCM7LfEdayERkjlR0IVQeVHI25+/JHPyk8YshZE5FFLELP5k1JMErsSh037
DPmjyPhdmL5LytWbA5HX
=b7tR
-----END PGP SIGNATURE-----

--bpVaumkpfGNUagdU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
