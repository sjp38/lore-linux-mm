Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id CE4766B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 19:12:44 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id rp16so1773699pbb.40
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 16:12:44 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id po10si3664099pab.102.2014.03.05.16.12.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Mar 2014 16:12:42 -0800 (PST)
Date: Thu, 6 Mar 2014 11:12:29 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2014-03-05-15-50 uploaded
Message-Id: <20140306111229.7e9821f6171c15c6d7b95bd6@canb.auug.org.au>
In-Reply-To: <20140305235119.DE4EE31C369@corp2gmr1-1.hot.corp.google.com>
References: <20140305235119.DE4EE31C369@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__6_Mar_2014_11_12_29_+1100_tlJ7ouoTJSu7ENbK"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

--Signature=_Thu__6_Mar_2014_11_12_29_+1100_tlJ7ouoTJSu7ENbK
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 05 Mar 2014 15:51:19 -0800 akpm@linux-foundation.org wrote:
>
> The mm-of-the-moment snapshot 2014-03-05-15-50 has been uploaded to
>=20
>    http://www.ozlabs.org/~akpm/mmotm/
>=20
> mmotm-readme.txt says
>=20
> README for mm-of-the-moment:
>=20
> http://www.ozlabs.org/~akpm/mmotm/

	.
	.

>   linux-next.patch
> * drivers-gpio-gpio-zevioc-fix-build.patch

I will drop this patch in linux-next as I have reverted the commit that
introduces that driver until it is fixed.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__6_Mar_2014_11_12_29_+1100_tlJ7ouoTJSu7ENbK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTF712AAoJEMDTa8Ir7ZwV4KwP/jBr9+EqR6rp2SUbpnxAAB01
NtDLX7HItpUovaFFvo9XSgmMU1VtNqVv28XidTRBI0sggHpdedxC8Ss3ynQGy+nY
N04BSI12LsVcAR5dU04Z2B9LMo8WVYo0W0lMgE/8ZHagyhoHph82PzNrMiKUSk9h
osvdz6cOI+IJLZmD83HYI1RaWTNP0ZGbuGhdXeh7iRXVLVcHhUdZadA9Y8lS5Rpy
lAdrKvLOPMvksXPkqWgCgEO6K7fEK2JSL0pttfH3lOFcdC7M8asjLG9x4OVYbEAC
3X9rr+W1bV/18slke6bwtQgCqM+IaWGKMGWejvfl4OWiWEOEcf7XuFaSAnr3qziD
yWhVzIJI48v3HdEO9ji6IhupxdDKrf1p2hQEUCkkk7OUSLBaLsWOUrcaDZdYVnbO
lnz6wmsS4UwdUP1LKR/miX2fus7hGMoG4Uo/fzXWGGDMmOLN9amlGPO+mK/IDlvp
C6a5bkZcHZjrqhwwbbAy6kIUxqebd+faYuPCj9v8BnrTN9umbViaAtWYDAPqcJEz
Ubfxte/J6/I0heXL4oWykel8TP9haN0HOjub7yvOOXx/WCga+Do0Ekk/RffW3vJW
ji2Llse/NPOE5VmLWto5u65hMVUD+ELj41v+I/7L2H8yWxVwyVw/9hpf9wCx9rd2
Ur1QXHuJdu1ycyj0xjjv
=qdOE
-----END PGP SIGNATURE-----

--Signature=_Thu__6_Mar_2014_11_12_29_+1100_tlJ7ouoTJSu7ENbK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
