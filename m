Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 731B66B005A
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 08:44:26 -0400 (EDT)
Message-ID: <1348490649.11847.59.camel@twins>
Subject: Re: [PATCH v10 1/5] mm: introduce a common interface for balloon
 pages mobility
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 24 Sep 2012 14:44:09 +0200
In-Reply-To: <89c9f4096bbad072e155445fcdf1805d47ddf48e.1347897793.git.aquini@redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
	 <89c9f4096bbad072e155445fcdf1805d47ddf48e.1347897793.git.aquini@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 2012-09-17 at 13:38 -0300, Rafael Aquini wrote:
> +static inline void assign_balloon_mapping(struct page *page,
> +                                         struct address_space
> *mapping)
> +{
> +       page->mapping =3D mapping;
> +       smp_wmb();
> +}
> +
> +static inline void clear_balloon_mapping(struct page *page)
> +{
> +       page->mapping =3D NULL;
> +       smp_wmb();
> +}=20

barriers without a comment describing the data race are a mortal sin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
