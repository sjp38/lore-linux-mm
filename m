Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 164636B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 08:48:14 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so1468727pac.17
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 05:48:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id sj7si2331929pbc.44.2014.07.30.05.48.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 05:48:13 -0700 (PDT)
Date: Wed, 30 Jul 2014 14:47:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH] mm: Add helpers for locked_vm
Message-ID: <20140730124748.GK19379@twins.programming.kicks-ass.net>
References: <1406712493-9284-1-git-send-email-aik@ozlabs.ru>
 <1406716282.9336.16.camel@buesod1.americas.hpqcorp.net>
 <53D8E578.7060303@ozlabs.ru>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H+pqIWPix3sfwaup"
Content-Disposition: inline
In-Reply-To: <53D8E578.7060303@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Jo\"rn Engel" <joern@logfs.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Michael Ellerman <michael@ellerman.id.au>


--H+pqIWPix3sfwaup
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 30, 2014 at 10:30:48PM +1000, Alexey Kardashevskiy wrote:
>=20
> No, this is not my intention here. Here I only want to increment the coun=
ter.

Full and hard nack on that. It should always be tied to actual pages, we
should not detach this and make it 'a number'.



--H+pqIWPix3sfwaup
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT2OlnAAoJEHZH4aRLwOS6nFUP/2U1vEbRt92TDziwqtL2/HBZ
Nm+eMGwPbUoDQOF/J+aXiD3QDX+7nsyK09bHShwKSv6GidCopO14prSIlPsT0LyN
NYleSCoIbKrKXttHpxGFftUJNaw6Cos/IUSrDn+nRXdLSLpnUBMmciVKlJ3ebaVu
PO2ieMWEW8hmHKINSxpVS5IMLf4AmSW3+pO93J+0lIGcLb/WMwS1sOqmuIyxM1Fm
LqtsQax5uJZHHdbl3q38/Eq3B0FV3k6VUwRbBYtedW8uUjqe6fhRXLQNHZRcGTa5
vr6EYAi7hFCKarodaxmujJNl/Pt17Bkes98UmZsod341wjhqedWs8kPNZOvS65dB
jHmaa/x7oXS8B0UyNQdAtsqTAUYezF/sXrAsUYh8XARZvhmVwcaeATtSqXT4Y1SM
IgxPiSel9YcQivUTs/jbn0qhzFhCALjC8yuxvMBxdPdVOWyQ9+npomYJayTjIHQX
6zN0KnhcvpS9znk9maphhrx0LGE7tNfIwIcVUvb91joNsgD9hhmS2AIAiLln3g/1
LoHz9UFLPpTqc0dFbOV0Ipm2gHRseSImcCPJ96bxMHgQrf6cCMzbHoImqtiXlJ1Z
kBTHKWUPa4wxbIyL3D8Xj3E6nsIMgL9rixTFphRrbpf6OHq768yGhv+vSnwPPE0W
OCfkD5HyZNCpquqj1CkO
=+FSo
-----END PGP SIGNATURE-----

--H+pqIWPix3sfwaup--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
