Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id EECD26B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 11:20:23 -0400 (EDT)
Message-ID: <1345562411.23018.111.camel@twins>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 21 Aug 2012 17:20:11 +0200
In-Reply-To: <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
	 <e24f3073ef539985dea52943dcb84762213a0857.1345519422.git.aquini@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, paulmck <paulmck@linux.vnet.ibm.com>

On Tue, 2012-08-21 at 09:47 -0300, Rafael Aquini wrote:
> +       mapping =3D rcu_access_pointer(page->mapping);
> +       if (mapping)
> +               mapping =3D mapping->assoc_mapping;=20

The comment near rcu_access_pointer() explicitly says:

 * Return the value of the specified RCU-protected pointer, but omit the
 * smp_read_barrier_depends() and keep the ACCESS_ONCE().  This is useful
 * when the value of this pointer is accessed, but the pointer is not
 * dereferenced,

Yet you dereference the pointer... smells like fail to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
