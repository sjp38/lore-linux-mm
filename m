Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 759236B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 11:34:34 -0400 (EDT)
Message-ID: <1345563260.26596.0.camel@twins>
Subject: Re: [PATCH v8 3/5] virtio_balloon: introduce migration primitives
 to balloon pages
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 21 Aug 2012 17:34:20 +0200
In-Reply-To: <20120821144013.GA7784@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
	 <c5f02c618c99b0da11240c1b504672de6f70a074.1345519422.git.aquini@redhat.com>
	 <20120821144013.GA7784@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, 2012-08-21 at 17:40 +0300, Michael S. Tsirkin wrote:
> > +     vb->balloon_status =3D BALLOON_REMOVAL;
>=20
> This needs some kind of barrier.
>=20
> >       kthread_stop(vb->thread);=20

kthread_stop() implies an smp_wmb() [ because it needs to do a wakeup ].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
