Subject: Re: [patch 3/3] mm: variable length argument support
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070822084852.GA12314@localdomain>
References: <20070613100334.635756997@chello.nl>
	 <20070613100835.014096712@chello.nl>  <20070822084852.GA12314@localdomain>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WTREF37w6MqqyimV8o8b"
Date: Wed, 22 Aug 2007 10:54:02 +0200
Message-Id: <1187772842.6114.282.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dan Aloni <da-x@monatomic.org>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

--=-WTREF37w6MqqyimV8o8b
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-08-22 at 11:48 +0300, Dan Aloni wrote:
> On Wed, Jun 13, 2007 at 12:03:37PM +0200, Peter Zijlstra wrote:
> > From: Ollie Wild <aaw@google.com>
> >=20
> > Remove the arg+env limit of MAX_ARG_PAGES by copying the strings direct=
ly
> > from the old mm into the new mm.
> >=20
> [...]
> > +static int __bprm_mm_init(struct linux_binprm *bprm)
> > +{
> [...]
> > +	vma->vm_flags =3D VM_STACK_FLAGS;
> > +	vma->vm_page_prot =3D protection_map[vma->vm_flags & 0x7];
> > +	err =3D insert_vm_struct(mm, vma);
> > +	if (err) {
> > +		up_write(&mm->mmap_sem);
> > +		goto err;
> > +	}
> > +
>=20
> That change causes a crash in khelper when overcommit_memory =3D 2=20
> under 2.6.23-rc3.
>=20
> When a khelper execs, at __bprm_mm_init() current->mm is still NULL.
> insert_vm_struct() calls security_vm_enough_memory(), which calls=20
> __vm_enough_memory(), and that's where current->mm->total_vm gets=20
> dereferenced.

Alan proposed this patch:

http://lkml.org/lkml/2007/8/13/782


--=-WTREF37w6MqqyimV8o8b
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGy/mqXA2jU0ANEf4RAoVpAKCSMxZaGuYNAynaPsaVWiuvpJUuIACfY3+N
NkHk8qBgDocjzHNb6QoNC80=
=zANN
-----END PGP SIGNATURE-----

--=-WTREF37w6MqqyimV8o8b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
