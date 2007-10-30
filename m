Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0710301535270.9322@blonde.wat.veritas.com>
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
	 <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
	 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
	 <1193738177.27652.69.camel@twins>
	 <45a44e480710300616p34b0a159m87de78d0a4d43028@mail.gmail.com>
	 <1193750751.27652.86.camel@twins>
	 <Pine.LNX.4.64.0710301535270.9322@blonde.wat.veritas.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-19tc5Np9Tlb3uJm+SUPC"
Date: Tue, 30 Oct 2007 16:51:02 +0100
Message-Id: <1193759462.27652.88.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jaya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-19tc5Np9Tlb3uJm+SUPC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-30 at 15:47 +0000, Hugh Dickins wrote:
> On Tue, 30 Oct 2007, Peter Zijlstra wrote:
> > On Tue, 2007-10-30 at 09:16 -0400, Jaya Kumar wrote:
> ....
> > > - defio mmap adds this vma to private list (equivalent of
> > > address_space or anon_vma)
> ....
> > > - foreach vma { foreach page { page_mkclean_one(page, vma) }
> >=20
> > Yeah, page_mkclean_one(page, vma) will use vma_address() to obtain an
> > user-space address for the page in this vma using page->index and the
> > formula from the last email, this address is then used to walk the page
> > tables and obtain a pte.
>=20
> I don't understand why you suggested an anon_vma, nor why Jaya is
> suggesting a private list.  All vmas mapping /dev/fb0 will be kept
> in the prio_tree rooted in its struct address_space (__vma_link_file
> in mm/mmap.c).  And page_mkclean gets page_mkclean_file to walk that
> very tree.  The missing part is just the setting of page->mapping to
> point to that struct address_space (and clearing it before finally
> freeing the pages), and the setting of page->index as you described.
> Isn't it?

Hmm, there is a thought. I had not considered that mapping a chardev
would have that effect.

I'd have to have a look at the actual code, but yeah, that might very
well work out. How silly of me.

Thanks!

--=-19tc5Np9Tlb3uJm+SUPC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHJ1LmXA2jU0ANEf4RAtAVAJ9i89150XfjGYw/CGSzx4C+V7sdWQCePo+z
Xn/BLOvy8weUS2EUoyG7AKk=
=KNkc
-----END PGP SIGNATURE-----

--=-19tc5Np9Tlb3uJm+SUPC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
