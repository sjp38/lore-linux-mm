Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 580D5600385
	for <linux-mm@kvack.org>; Mon, 17 May 2010 09:48:12 -0400 (EDT)
Received: by wwa36 with SMTP id 36so2150036wwa.14
        for <linux-mm@kvack.org>; Mon, 17 May 2010 06:48:10 -0700 (PDT)
Date: Mon, 17 May 2010 14:48:03 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] Split executable and non-executable mmap tracking
Message-ID: <20100517134803.GC8042@us.ibm.com>
References: <1273223135-22695-1-git-send-email-ebmunson@us.ibm.com>
 <1274102475.1674.1494.camel@laptop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i7F3eY7HS/tUJxUd"
Content-Disposition: inline
In-Reply-To: <1274102475.1674.1494.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@elte.hu, acme@redhat.com, arjan@linux.intel.com, anton@samba.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--i7F3eY7HS/tUJxUd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 17 May 2010, Peter Zijlstra wrote:

> On Fri, 2010-05-07 at 10:05 +0100, Eric B Munson wrote:
> > This patch splits tracking of executable and non-executable mmaps.
> > Executable mmaps are tracked normally and non-executable are
> > tracked when --data is used.
> >=20
> > Signed-off-by: Anton Blanchard <anton@samba.org>
> >=20
> > Updated code for stable perf ABI
> > Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
>=20
> > +++ b/include/linux/perf_event.h
> > @@ -197,6 +197,7 @@ struct perf_event_attr {
> >  				exclude_hv     :  1, /* ditto hypervisor      */
> >  				exclude_idle   :  1, /* don't count when idle */
> >  				mmap           :  1, /* include mmap data     */
> > +				mmap_exec      :  1, /* include exec mmap data*/
> >  				comm	       :  1, /* include comm data     */
> >  				freq           :  1, /* use freq, not period  */
> >  				inherit_stat   :  1, /* per task counts       */
>=20
> You cannot add a field in the middle, that breaks ABI.
>=20
> > -static inline void perf_event_mmap(struct vm_area_struct *vma)
> > -{
> > -	if (vma->vm_flags & VM_EXEC)
> > -		__perf_event_mmap(vma);
> > -}
>=20
> Also, the current behaviour of perf_event_attr::mmap() is to trace
> VM_EXEC maps only, apps relying on that will be broken after this patch
> because they'd have to set mmap_exec.
>=20
> If you want to do this, you'll have to add mmap_data (to the tail of the
> bitfield) and have that add !VM_EXEC mmap() tracing.
>=20

Thanks, I will get right on the changes.

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--i7F3eY7HS/tUJxUd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvxSRMACgkQsnv9E83jkzoQrQCg9CxWdhcopS4sKyhssJ7GBHgP
YVQAoL9S5VaQg8uvtiyIlniT+2cU1T36
=6EoU
-----END PGP SIGNATURE-----

--i7F3eY7HS/tUJxUd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
