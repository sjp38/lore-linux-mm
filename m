Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id EBF226B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 09:00:42 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so6299160wiw.9
        for <linux-mm@kvack.org>; Wed, 07 May 2014 06:00:42 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gd15si5714886wic.121.2014.05.07.06.00.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 May 2014 06:00:41 -0700 (PDT)
Date: Wed, 7 May 2014 15:00:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140507130032.GM30445@twins.programming.kicks-ass.net>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
 <20140506102925.GD11096@twins.programming.kicks-ass.net>
 <1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dFWYt1i2NyOo1oI9"
Content-Disposition: inline
In-Reply-To: <1399429987.2581.25.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: j.glisse@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>


--dFWYt1i2NyOo1oI9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 06, 2014 at 07:33:07PM -0700, Davidlohr Bueso wrote:

> So I've been running benchmarks (mostly aim7, which nicely exercises our
> locks) comparing my recent v4 for rwsem optimistic spinning against
> previous implementation ideas for the anon-vma lock, mostly:

> - rwlock_t
> - qrwlock_t

Which reminds me; can you provide the numbers for rwlock_t vs qrwlock_t
in a numeric form so I can include them in the qrwlock_t changelog.

That way I can queue those patches for inclusion, I think we want a fair
rwlock_t if we can show (and you graphs do iirc) that it doesn't cost us
performance.

--dFWYt1i2NyOo1oI9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTai5vAAoJEHZH4aRLwOS6YYUP/RtUsgGqFomp72pmfY168EHN
qMrtaqJo+4IyBSOkXoZJAF3m+7zAUo3tvkE0KzMf21LMCYHqcHvUlKxR9DZPmv9T
28JNn7aZ1tbYYRb6NqsfNrdfX/0pfb4exLaf4v2mr8dFsRUyntnr6WxMzfFR/uSm
kwuGTVfTmxvDHZxafDIbq4C9p8uEApK8CvP1zYRATyDeziKnxaVhgUcj2Sob2ez4
kwLqUyJgwlqF7sMEprgftceMqGu9PEuvNhJtBFI2x8c4ns7yY5QAj+WAbfjoiB7i
guRnS+PoPN6jNg9QZO9aDq478OlukcZ1GYLi05EG8n2SVjEv4U558ZNwUiBZ7wQy
g52QT1tBGUNj8pQVbi+xtu+A7opXrfrTeokSHQDStyf1kCUzbkImeqjFsu7McJsW
dx/bnouiVWXgNFtyGqAnOUFeKJvC6k+E7rgBNIReN172tnTQCjONMGet8VKJ6HEj
4HFwJ3zxhwr34CXg1YBZALIAC7wshFMxIYFedNKlRJEjiK5X5og/0VEfFA3Ud3OB
vqfWX71wnSwZ5VLs+qxN+sTLkxIqOwhlhQCZBShQZmQmIL1RDrjNQ8lgGwsfQnEt
opJUcXqV54Tzs5MHTdJOnbcpuN2XV/sUWbQdxfnwT+XZX1P+V0ya4gfXAbaznbxQ
Wz8aDpj+naso6pc6b3aA
=wd3z
-----END PGP SIGNATURE-----

--dFWYt1i2NyOo1oI9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
