Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 5897C6B0074
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 11:16:25 -0400 (EDT)
Message-ID: <1345562166.23018.109.camel@twins>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 21 Aug 2012 17:16:06 +0200
In-Reply-To: <20120821135223.GA7117@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
	 <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
	 <20120821135223.GA7117@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, 2012-08-21 at 16:52 +0300, Michael S. Tsirkin wrote:
> > +             rcu_read_lock();
> > +             mapping =3D rcu_dereference(page->mapping);
> > +             if (mapping_balloon(mapping))
> > +                     ret =3D true;
> > +             rcu_read_unlock();
>=20
> This looks suspicious: you drop rcu_read_unlock
> so can't page switch from balloon to non balloon?=20

RCU read lock is a non-exclusive lock, it cannot avoid anything like
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
