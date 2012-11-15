Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 540A86B009E
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:45:33 -0500 (EST)
Date: Thu, 15 Nov 2012 10:46:35 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 05/11] thp: change_huge_pmd(): keep huge zero page
 write-protected
Message-ID: <20121115084635.GC9676@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-6-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141512400.22537@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/Uq4LBwYP4y1W6pO"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141512400.22537@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--/Uq4LBwYP4y1W6pO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 03:12:54PM -0800, David Rientjes wrote:
> On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index d767a7c..05490b3 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1259,6 +1259,8 @@ int change_huge_pmd(struct vm_area_struct *vma, p=
md_t *pmd,
> >  		pmd_t entry;
> >  		entry =3D pmdp_get_and_clear(mm, addr, pmd);
> >  		entry =3D pmd_modify(entry, newprot);
> > +		if (is_huge_zero_pmd(entry))
> > +			entry =3D pmd_wrprotect(entry);
> >  		set_pmd_at(mm, addr, pmd, entry);
> >  		spin_unlock(&vma->vm_mm->page_table_lock);
> >  		ret =3D 1;
>=20
> Nack, this should be handled in pmd_modify().

I disagree. It means we will have to enable hzp per arch. Bad idea.

What's wrong with the check?

--=20
 Kirill A. Shutemov

--/Uq4LBwYP4y1W6pO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpKvrAAoJEAd+omnVudOMbAIQALQYjNB3Ykp89rdxhWu5HWvV
qp0eBB9WHuD3AK9ezQVWFY8jKijlxELc/NPbJStlfe5PMSkYtUkpl3Iju8n3khd0
BUA1tSrdLOnAW3efpisTN9BvBP+0mPrY9TynPGuYDjO2qFOOLoXNYqUmeE9GmVFv
HGVcfxQ4I2331qFr9m35+/Wt4W/Fe+QqIDsQ725ESr8YFDNcyp4wKXo2roZER4+h
nT27KQmktCyTNlu9htYecHKR3RgonxUyoWd4WRlo+ofWiJhVdQP92QcQuQUgS56u
46UG9S+vDcs5TaJUg/T7RuFNLylUuq3S192NTs29Ou7EqTwWw13o+DjRmP24reRS
VutQaklLFcW6dKUW79rk8f/6WUPgjGfk2eF4Ix6ceR0CaxA8EjZPcWoWb1orob+M
mf4qTt0wXURcF3wvgS7S1eI7bi/8z+x+bjWVNPF1gHZAeUDsalN+NWeT6Lk2pil0
mIgjeLBBnrhHRppgpWFZaqaIqPDxjsmA6bMcHzpZyG/zfHhj10McdT24Olyh0tbr
8zHXZSA2X7R/V4nrgp6/UM7Vx+36b6FEYZBBMs8rSsoYj0H4DaXRBrECInbXATEq
Nv+qeuUnB5D3B8e9V1bilTii57JXIcTozsJMUSVBW6yuTm5IVFPSpbQsHb7QzFAp
z6rStm5r0x2rRYIGSnw0
=eKdr
-----END PGP SIGNATURE-----

--/Uq4LBwYP4y1W6pO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
