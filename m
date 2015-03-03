Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 37EFB6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:41:07 -0500 (EST)
Received: by pdjy10 with SMTP id y10so50124278pdj.6
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:41:07 -0800 (PST)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id zv9si1993094pbc.26.2015.03.03.09.41.06
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 09:41:06 -0800 (PST)
Date: Tue, 3 Mar 2015 12:41:05 -0500
From: Eric B Munson <emunson@akamai.com>
Subject: Resurrecting the VM_PINNED discussion
Message-ID: <20150303174105.GA3295@akamai.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

All,

After LSF/MM last year Peter revived a patch set that would create
infrastructure for pinning pages as opposed to simply locking them.
AFAICT, there was no objection to the set, it just needed some help
=66rom the IB folks.

Am I missing something about why it was never merged?  I ask because
Akamai has bumped into the disconnect between the mlock manpage,
Documentation/vm/unevictable-lru.txt, and reality WRT compaction and
locking.  A group working in userspace read those sources and wrote a
tool that mmaps many files read only and locked, munmapping them when
they are no longer needed.  Locking is used because they cannot afford a
major fault, but they are fine with minor faults.  This tends to
fragment memory badly so when they started looking into using hugetlbfs
(or anything requiring order > 0 allocations) they found they were not
able to allocate the memory.  They were confused based on the referenced
documentation as to why compaction would continually fail to yield
appropriately sized contiguous areas when there was more than enough
free memory.

I would like to see the situation with VM_LOCKED cleared up, ideally the
documentation would remain and reality adjusted to match and I think
Peter's VM_PINNED set goes in the right direction for this goal.  What
is missing and how can I help?

Thanks,
Eric

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU9fIxAAoJELbVsDOpoOa9fhIQANddQaLa/xGNR1aFZx7HdBK3
FbE0KtCituCbCv/qXJ6C/4yJEGqW08gH9CGoVRGiE4Q+5hAHg4sBlMySOQH19M15
2WtQ+m2j169MuXvhZwzNv2olR9WpvoMBqIsaG5wDUgGCIRr1WFlTZcOgstgla87A
+UeFryrytITupVtXIFJMdmi8H/wNhgyYDR2LRv8dKQNj7+cpQRiifmxeNS9Q7SfU
2LWxwwaK84G90cBaf3tEPA1Sfp6KhUZ9rG/WTjPv4iWVkXSYV4ru8MIBI9/m9Zz9
/qV6lDfMeRwph5riUg6UA5ZXlLClbwLO74S/OIdkjMIBWsyQRSzJTmOCX/q+j3B+
dA7HDlqI7g+ppo9mHCRHKKvmj0suxH5GS/GXeLPWz2s0HWzyFWGLbqlLDEi7UGCG
XT04ToeUt7rsR9TmX79MpiQz/z8/exrvaaYveS3Ds+BBqw4z1hflp4JtIYvwlquy
YO1eIyTqZ8cxwTwyaA5eA1xJZnkesDfoMCxYsQduNVNUpfphTX9UA1pAfRG06we4
4AeGK0rDEpG3h8idG9rFX2xS9/kjJk647nWt7qv8FxCVo9+mQuGonIG29bBzcnOq
9oRuXLs7yEmzZWUVlJCKGOtp1AcWryAdIJ3NbHPVljF4bzjb631DPnF4pRqOnIMh
oWlnIe/hJs4XqYZInIM9
=fVgt
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
