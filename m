Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BE0386B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 13:45:27 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so19320183pdb.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 10:45:27 -0800 (PST)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id dh1si2132656pbd.62.2015.03.03.10.45.25
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 10:45:26 -0800 (PST)
Date: Tue, 3 Mar 2015 13:45:20 -0500
From: Eric B Munson <emunson@akamai.com>
Subject: Re: Resurrecting the VM_PINNED discussion
Message-ID: <20150303184520.GA4996@akamai.com>
References: <20150303174105.GA3295@akamai.com>
 <54F5FEE0.2090104@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <54F5FEE0.2090104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 03 Mar 2015, Vlastimil Babka wrote:

> On 03/03/2015 06:41 PM, Eric B Munson wrote:> All,
> >
> > After LSF/MM last year Peter revived a patch set that would create
> > infrastructure for pinning pages as opposed to simply locking them.
> > AFAICT, there was no objection to the set, it just needed some help
> > from the IB folks.
> >
> > Am I missing something about why it was never merged?  I ask because
> > Akamai has bumped into the disconnect between the mlock manpage,
> > Documentation/vm/unevictable-lru.txt, and reality WRT compaction and
> > locking.  A group working in userspace read those sources and wrote a
> > tool that mmaps many files read only and locked, munmapping them when
> > they are no longer needed.  Locking is used because they cannot afford a
> > major fault, but they are fine with minor faults.  This tends to
> > fragment memory badly so when they started looking into using hugetlbfs
> > (or anything requiring order > 0 allocations) they found they were not
> > able to allocate the memory.  They were confused based on the referenced
> > documentation as to why compaction would continually fail to yield
> > appropriately sized contiguous areas when there was more than enough
> > free memory.
>=20
> So you are saying that mlocking (VM_LOCKED) prevents migration and thus
> compaction to do its job? If that's true, I think it's a bug as it is AFA=
IK
> supposed to work just fine.

Agreed.  But as has been discussed in the threads around the VM_PINNED
work, there are people that are relying on the fact that VM_LOCKED
promises no minor faults.  Which is why the behavoir has remained.

>=20
> > I would like to see the situation with VM_LOCKED cleared up, ideally the
> > documentation would remain and reality adjusted to match and I think
> > Peter's VM_PINNED set goes in the right direction for this goal.  What
> > is missing and how can I help?
>=20
> I don't think VM_PINNED would help you. In fact it is VM_PINNED that impr=
oves
> accounting for the kind of locking (pinning) that *does* prevent page mig=
ration
> (unlike mlocking)... quoting the patchset cover letter:

VM_PINNED itself doesn't help us, but it would allow us to make
VM_LOCKED use only the weaker 'no major fault' semantics while still
providing a way for anyone that needs the stronger 'no minor fault'
promise to get the semantics they need.

>=20
> "These patches introduce VM_PINNED infrastructure, vma tracking of persis=
tent
> 'pinned' page ranges. Pinned is anything that has a fixed phys address (as
> required for say IO DMA engines) and thus cannot use the weaker VM_LOCKED=
=2E One
> popular way to pin pages is through get_user_pages() but that not nesseca=
rily
> the only way."
>=20
> > Thanks,
> > Eric
> >
>=20

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU9gFAAAoJELbVsDOpoOa9gO4QAJXYwGbucM1OKu3lHZlZ8lcH
HJUK+qLRt2AbCkCs+T0CTmZm6pe683/IEFrhOotgte3wt9a93/TgmDwEyM6eaL9Y
ekXnWREvtOnt+wzpMM/E8/F+308aB63cZBv20ur/JPbb3ochMzWmZem+U6oFFXpV
51gPDsK6aaghgR+HTmcSg9xd9v0m60xEK0o6r08TrUsbJwRFhvwf4I/WCJUQM+ss
a2iJFn25XKnHStINHgPo9iANRrNaN+dt0eCCT1YgyfvhCXNXrk+Rn5DYkY5rsCKj
eY3kxf+N+PYrmQ+54xAh448Dvj4DZm79FJVGRskjcKl/NrUGCZX0+B0bg57mxJLn
njuUpyMAuG+FSLINXTiTkXpZrVZBDaf/UtfiCn676qS7DMpfBi9go8RBSN4YDeyB
hl+42vm8TUhGdlpFqeTSB6f/5KKqi0SQ2q3TnU4KVwQXu3BJ75U3pdaINGotlny4
qQdWlPLNKw7+oc84SIGJ8jtbPv+DCgBvMBhFiAYoYS7j6PV297q62hmk+o7n8eMK
pNDZPSzplxoLJj1PHiU+Me8Im0w4iPPADuYeMbAjQFaCJF8PkWutLpj3atvLu934
+tpHcmo3vOJdvm/fYepRcw+DmkC2WSke4SWyrFMY3xTlwlWoCd5K2fqKXwKm3D1m
IR2SEuw6MbBCQpcLVEWO
=qx/S
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
