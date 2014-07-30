Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B106D6B0038
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 06:12:38 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so1216693pdj.35
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 03:12:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id qo7si1846263pac.190.2014.07.30.03.12.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 03:12:37 -0700 (PDT)
Date: Wed, 30 Jul 2014 12:12:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH] mm: Add helpers for locked_vm
Message-ID: <20140730101218.GG19379@twins.programming.kicks-ass.net>
References: <1406712493-9284-1-git-send-email-aik@ozlabs.ru>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YuRE/gUr1KgjPX1R"
Content-Disposition: inline
In-Reply-To: <1406712493-9284-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Davidlohr Bueso <davidlohr@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Michael Ellerman <michael@ellerman.id.au>


--YuRE/gUr1KgjPX1R
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 30, 2014 at 07:28:13PM +1000, Alexey Kardashevskiy wrote:
> This adds 2 helpers to change the locked_vm counter:
> - try_increase_locked_vm - may fail if new locked_vm value will be greater
> than the RLIMIT_MEMLOCK limit;
> - decrease_locked_vm.
>=20
> These will be used by drivers capable of locking memory by userspace
> request. For example, VFIO can use it to check if it can lock DMA memory
> or PPC-KVM can use it to check if it can lock memory for TCE tables.

Urgh no.. have a look here:

lkml.kernel.org/r/20140526145605.016140154@infradead.org

Someone needs to go help with the IB stuff, I got properly lost in
there.

--YuRE/gUr1KgjPX1R
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT2MUCAAoJEHZH4aRLwOS6tgcP/irknQ9NQqFgjP6iEkuuxHin
7HpyR+dr0RJnCyp6aqaneqfIX6MtyUnIVUsxPegu6OEGHwbYWE+D2XWZAbXHaMdW
GC2J6wCMw6YVBuBoXaUIxlmgL/VVcXuDluMkww6b3roBmF4jW+0jjIVG8hkX6DUl
YaG/cv6Kclu4vS4f+hXOMEd/rd+PJMl9O8Kk8yzcHGXfcBt2IOTqiiHwG/GX2XTw
1h6QvPid6SWLQ6EbHVZZd95/jgAowkwuVJZddlBxUwd839mg4+i/ypMtu7YXz5dN
x25Nvo6w+8sCQcq1G1GACaWcJTsKJhAjew90nF33EGU+PjqzgWJdwN07gBQa9zjV
F5pVrc2aYAGJWsxGTtq4kDD6w3B3oh1AKlv2/SAYA6koX29OGFi9WN5hUWOm3MG8
LIqwqhfuhL0tWFAbn9dP3IFHzeMjCyeyhpQMxIL2bqMFHicqk/+qz87ol9l69Qg1
Bwip5wxihkTQ9nfzK7FcUBthI3Hy4a09gXZm3KdpxvPoa9ZdfXfxuNF/gSRcfoHy
jzazCcWD+rZIMLPy509v49223MD9j4peSNjd3E64GlZFQqHHezDSUiNY6dl/jT39
XUTpoBdWXvQAb1z3YOYVDRNDIoDQroXQdelggdcACPn2aqj+kyXnB73+K6L+OGAC
tSxKdbkan5Zdl6BRbSx8
=zcmc
-----END PGP SIGNATURE-----

--YuRE/gUr1KgjPX1R--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
