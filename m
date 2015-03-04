Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E28106B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 09:45:46 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so20737256pdb.7
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 06:45:46 -0800 (PST)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id e6si510082pdo.202.2015.03.04.06.45.45
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 06:45:46 -0800 (PST)
Date: Wed, 4 Mar 2015 09:45:45 -0500
From: Eric B Munson <emunson@akamai.com>
Subject: Re: Resurrecting the VM_PINNED discussion
Message-ID: <20150304144544.GC6995@akamai.com>
References: <20150303174105.GA3295@akamai.com>
 <54F5FEE0.2090104@suse.cz>
 <20150303184520.GA4996@akamai.com>
 <54F617A2.8040405@suse.cz>
 <20150303210150.GA6995@akamai.com>
 <20150303215258.GB6995@akamai.com>
 <54F6303C.5080806@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5QAgd0e35j3NYeGe"
Content-Disposition: inline
In-Reply-To: <54F6303C.5080806@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>


--5QAgd0e35j3NYeGe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 03 Mar 2015, Vlastimil Babka wrote:

<snip>
>=20
> No, you were correct and thanks for the hint. It's only ISOLATE_UNEVICTAB=
LE from
> isolate_migratepages_range(), which is CMA, not regular compaction.
> But I wonder, can we change this even after VM_PINNED is introduced, if e=
xisting
> code depends on "no minor faults in mlocked areas", whatever the docs say=
? On
> the other hand, compaction is not the only source of migrations. I wonder=
 what
> the NUMA balancing does (not) about mlocked areas...

My hope was that we could convince those that depend on mlock()
preventing minor faults to move to use the mpin() interface that was
discussed in the VM_PINNED thread.  If that is not acceptable then we
really need to update the man page for mlock() and the vm documentation
to be very clear that minor faults are also prevented.

Eric

--5QAgd0e35j3NYeGe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU9xqYAAoJELbVsDOpoOa98boQAIbmVQ8k52zlEjTfaksdmZ0B
9p9av7ZUYLdYCU94hydWbfrl5tdhrryE7/tQd6YHco7VCh2EqF1poR7Wx7RN0vGd
dI2UViYAgDrdOPirL4qMTf4QKCeeIjzR3BeH3AbVc4D9EQyZ5vtwcL610spkyGnT
jiHY1WF2Q5dF86V0TNndOXAjy8ja58z/aQUN10NkCuwVlxpIyPdTtoxSHmTfHpSy
00DXgmZmRpj6DJg7O0mpkAZCsUM97SJp2Ai6Cc+YRg1l7+GCxom1sV+sr9VPwoi9
M9DvlUTk/4TDc+4VZ8KgzUdoMcr0x0lQMwbeXTuYxrPqUIBsTCj2RZ5PyCImNk2T
QrUhP3RmO7WqFgq+iCEUyU6Mo+tAFxSL14QpiQUP6Ufq2V08oHVgiOCp2sAGz1/b
4Y4OXIhQFcocZSATesAMJHzvpRIq2QFXezZaFZwv8WpjiH4AwLoDic2uGJIYt3zI
W0boWmEg403+1ZavoqvFLMkO8S+AxpczvEYZ2zLPQmUnuIfQjnE8EJD2xqajlKdh
R1amg6sAHr1cFuPsrtux6LAdLkV2/qCIK3nJiDVUl/rjcAEJI9ZBV1e+AULN6sDp
8MQ83vsySq+r9C8hOOBUwva5L6asX3iqZQSmtQjI4emf+vafp2/gQZtx5GIoU+Si
/4yx6BTbfk/+xGQiruBK
=eds4
-----END PGP SIGNATURE-----

--5QAgd0e35j3NYeGe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
