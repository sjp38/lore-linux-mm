Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 962DB6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 16:01:53 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so20161306pdb.9
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 13:01:53 -0800 (PST)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id fa9si2483593pdb.76.2015.03.03.13.01.51
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 13:01:51 -0800 (PST)
Date: Tue, 3 Mar 2015 16:01:50 -0500
From: Eric B Munson <emunson@akamai.com>
Subject: Re: Resurrecting the VM_PINNED discussion
Message-ID: <20150303210150.GA6995@akamai.com>
References: <20150303174105.GA3295@akamai.com>
 <54F5FEE0.2090104@suse.cz>
 <20150303184520.GA4996@akamai.com>
 <54F617A2.8040405@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rwEMma7ioTxnRzrJ"
Content-Disposition: inline
In-Reply-To: <54F617A2.8040405@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 03 Mar 2015, Vlastimil Babka wrote:

> On 03/03/2015 07:45 PM, Eric B Munson wrote:
> > On Tue, 03 Mar 2015, Vlastimil Babka wrote:
> >=20
> >> On 03/03/2015 06:41 PM, Eric B Munson wrote:> All,
> >> >
> >> > After LSF/MM last year Peter revived a patch set that would create
> >> > infrastructure for pinning pages as opposed to simply locking them.
> >> > AFAICT, there was no objection to the set, it just needed some help
> >> > from the IB folks.
> >> >
> >> > Am I missing something about why it was never merged?  I ask because
> >> > Akamai has bumped into the disconnect between the mlock manpage,
> >> > Documentation/vm/unevictable-lru.txt, and reality WRT compaction and
> >> > locking.  A group working in userspace read those sources and wrote a
> >> > tool that mmaps many files read only and locked, munmapping them when
> >> > they are no longer needed.  Locking is used because they cannot affo=
rd a
> >> > major fault, but they are fine with minor faults.  This tends to
> >> > fragment memory badly so when they started looking into using hugetl=
bfs
> >> > (or anything requiring order > 0 allocations) they found they were n=
ot
> >> > able to allocate the memory.  They were confused based on the refere=
nced
> >> > documentation as to why compaction would continually fail to yield
> >> > appropriately sized contiguous areas when there was more than enough
> >> > free memory.
> >>=20
> >> So you are saying that mlocking (VM_LOCKED) prevents migration and thus
> >> compaction to do its job? If that's true, I think it's a bug as it is =
AFAIK
> >> supposed to work just fine.
> >=20
> > Agreed.  But as has been discussed in the threads around the VM_PINNED
> > work, there are people that are relying on the fact that VM_LOCKED
> > promises no minor faults.  Which is why the behavoir has remained.
>=20
> At least in the VM_PINNED thread after last lsf/mm, I don't see this ment=
ioned.
> I found no references to mlocking in compaction.c, and in migrate.c there=
's just
> mlock_migrate_page() with comment:
>=20
> /*
>  * mlock_migrate_page - called only from migrate_page_copy() to
>  * migrate the Mlocked page flag; update statistics.
>  */
>=20
> It also passes TTU_IGNORE_MLOCK to try_to_unmap(). So what am I missing? =
Where
> is this restriction?
>=20

I spent quite some time looking for it as well, it is in vmscan.c

int __isolate_lru_page(struct page *page, isolate_mode_t mode)
{
=2E..
        /* Compaction should not handle unevictable pages but CMA can do so=
 */
        if (PageUnevictable(page) && !(mode & ISOLATE_UNEVICTABLE))
                return ret;
=2E..



--rwEMma7ioTxnRzrJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU9iE+AAoJELbVsDOpoOa9RTIQAM3ADM/+FsAkL9EoGJj41ph5
ROi0MT9Q6hROBKgiQpo92Aqq6KHLtIi0XGaKPGjHUQ2NRqUxkPc7t14YqzfvUecD
t/tKfOpsgZ36xSNotUAtJjzYr1zmJe5dqDeDgW3MDvc/pMKmLXtkabqq3FsC/zyw
DuCE9+67bUXfYOF03vGZ10EqTD+lDUZJgLc5ggKRNJ8FSK3fTPc9lmbRvWPzyYFb
n9BihVdCXOo2QuYJkoU2gszxj0ICkWyELa6S5DaMYymVWFCIs3pkUZIGgG4gMiJ1
SPoBA5cga31NqDbRJwSYp+M6OlkQIQHIDdTfPVSgaayBBbywTo6yCQMqC/Se/olj
dYVt2vc83gEDyZ43ZPeZnyZ75jl2oXd6xaqEIKaCSBJ+e2145uINEtE6zdrR4Wox
7h4JdASy0Nitp9dLYq7CwCcb83CbhZZq9kgmH3e4hlODhwEIbN7Zel2lfF7NI3IX
mxQ3jB4Cq2zFzs4BXEl5kxNif2CIk6309TuJEcj3nlvVmQNGKaSKuxfbLam5T0xt
DyDaU+oOsqiBcuV1bZ4KCJkgIV9hDSSO6r8c6HnGF4ppDpE/EeqvQXmMsXV+Munh
7oDTrquqhn7ongHN+A1l7d8p3n8XTL+u1mdkggoJtanJP1RhWn0IwKp1YE6H00QD
KvjU5zcUUNxlAtG4KNWD
=mSHL
-----END PGP SIGNATURE-----

--rwEMma7ioTxnRzrJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
