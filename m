Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id E9CCF6B0253
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:33:49 -0400 (EDT)
Received: by qkep139 with SMTP id p139so7594602qke.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 14:33:49 -0700 (PDT)
Received: from prod-mail-xrelay06.akamai.com (prod-mail-xrelay06.akamai.com. [96.6.114.98])
        by mx.google.com with ESMTP id n189si3576790qhb.34.2015.08.19.14.33.48
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 14:33:48 -0700 (PDT)
Date: Wed, 19 Aug 2015 17:33:45 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150819213345.GB4536@akamai.com>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gj572EiMnwbLXET9"
Content-Disposition: inline
In-Reply-To: <20150812115909.GA5182@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org


--gj572EiMnwbLXET9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 12 Aug 2015, Michal Hocko wrote:

> On Sun 09-08-15 01:22:53, Eric B Munson wrote:
> > The cost of faulting in all memory to be locked can be very high when
> > working with large mappings.  If only portions of the mapping will be
> > used this can incur a high penalty for locking.
> >=20
> > For the example of a large file, this is the usage pattern for a large
> > statical language model (probably applies to other statical or graphical
> > models as well).  For the security example, any application transacting
> > in data that cannot be swapped out (credit card data, medical records,
> > etc).
> >=20
> > This patch introduces the ability to request that pages are not
> > pre-faulted, but are placed on the unevictable LRU when they are finally
> > faulted in.  The VM_LOCKONFAULT flag will be used together with
> > VM_LOCKED and has no effect when set without VM_LOCKED.
>=20
> I do not like this very much to be honest. We have only few bits
> left there and it seems this is not really necessary. I thought that
> LOCKONFAULT acts as a modifier to the mlock call to tell whether to
> poppulate or not. The only place we have to persist it is
> mlockall(MCL_FUTURE) AFAICS. And this can be handled by an additional
> field in the mm_struct. This could be handled at __mm_populate level.
> So unless I am missing something this would be much more easier
> in the end we no new bit in VM flags would be necessary.
>=20
> This would obviously mean that the LOCKONFAULT couldn't be exported to
> the userspace but is this really necessary?

Sorry for the latency here, I was on vacation and am now at plumbers.

I am not sure that growing the mm_struct by another flags field instead
of using available bits in the vm_flags is the right choice.  After this
patch, we still have 3 free bits on 32 bit architectures (2 after the
userfaultfd set IIRC).  The group which asked for this feature here
wants the ability to distinguish between LOCKED and LOCKONFAULT regions
and without the VMA flag there isn't a way to do that.

Do we know that these last two open flags are needed right now or is
this speculation that they will be and that none of the other VMA flags
can be reclaimed?


--gj572EiMnwbLXET9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV1PY5AAoJELbVsDOpoOa9zsoP/3ahfihft1e+paDsTj5WiDeT
StCcyumPdtkaY2lSmWziNJuddxSwuM+Epe+EUlnwSgS9H8GVd+ri4B/ULvVtE9qJ
ilAHMTgWJScSODwYaI6n2NUn2ot2ONoQJTcdDx8YF5XiwDLeffFGe6roNIHDa+i2
XvO3RutK3P3EbNx7Src92dYEmLlF/53ralTRBHkBQLAvVQx+bMCgL4G0Xmc938J+
kB1IpZzZtl54zsVNNE2YUcrvQeRdLOSkevztFbOfS8bmFpN2vFIu1AjdVnKvm5Ql
CwY84a9E3vDskCP+gY4Xy9/imrUUsp1B9lzPqbybgYcKULaxs8KFdS9BEhAaGbV2
MmGCQ220uAaJDzWV1sw1VU8c51l7fwV6+gXnJPEVM5cMCoelewbQFnx9MF+uQ9Hx
39z2UGBsMvsk8l8zI/bXmNaRyhnVhFo2Vle0Z0ugJBMVeOwt1otNIBN5rHIUYyBd
7zek6EIPQm0oh6vKLbf7cqEXufl2v1fP09IFXt0oE7HoYipJV9iJ4r2flIXWoKcn
bpxpvdvPZchZju79BWIGpmUbMIEd98GjeypByKJttD/I7+RB2WgT1nirDqsWDKtp
1/FKjqDFP6ER9xUHIjbqgp1iYNveOmrx/r2toLoJiKX5C7zt5I4XYMQNy3j0GCPZ
NElakxuNYzvrqmTPF+WW
=BK2n
-----END PGP SIGNATURE-----

--gj572EiMnwbLXET9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
