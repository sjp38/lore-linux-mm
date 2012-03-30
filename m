Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2347D6B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 12:15:04 -0400 (EDT)
Date: Fri, 30 Mar 2012 11:15:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
In-Reply-To: <4F74BB67.30703@gmail.com>
Message-ID: <alpine.DEB.2.00.1203301113530.22502@router.home>
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home> <4F6B7854.1040203@redhat.com> <alpine.DEB.2.00.1203221421570.25011@router.home> <4F74A344.7070805@redhat.com> <4F74BB67.30703@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: lwoodman@redhat.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

On Thu, 29 Mar 2012, KOSAKI Motohiro wrote:

> >
> > 		for_each_node_mask(s, tmp) {
> > +
> > +			/* IFF there is an equal number of source and
> > +			 * destination nodes, maintain relative node distance
> > +			 * even when source and destination nodes overlap.
> > +			 * However, when the node weight is unequal, never
> > move
> > +			 * memory out of any destination nodes */
> > +			if ((nodes_weight(*from_nodes) !=
> > nodes_weight(*to_nodes)) &&
> > +						(node_isset(s, *to_nodes)))
> > +				continue;
> > +
> > 			d = node_remap(s, *from_nodes, *to_nodes);
> > 			if (s == d)
> > 				continue;
>
> I'm confused. Could you please explain why you choose nodes_weight()? On my
> first impression,
> it seems almostly unrelated factor.

Isnt this the original code by Paul? I would think that the 1-1 movement
is only useful to do if the number of nodes in both the destination and
the source is the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
