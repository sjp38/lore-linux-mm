Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B09416B004D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:41:54 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AF8F182C729
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:48:55 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5lTYh5JURsOa for <linux-mm@kvack.org>;
	Thu, 19 Mar 2009 18:48:49 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9B19E82C7BA
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:48:49 -0400 (EDT)
Date: Thu, 19 Mar 2009 18:39:31 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for
 num_online_nodes()
In-Reply-To: <20090319220641.GC24586@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903191834190.15549@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161207500.32577@qirst.com> <20090316163626.GJ24293@csn.ul.ie> <alpine.DEB.1.10.0903161247170.17730@qirst.com>
 <20090318150833.GC4629@csn.ul.ie> <alpine.DEB.1.10.0903181256440.15570@qirst.com> <20090318180152.GB24462@csn.ul.ie> <alpine.DEB.1.10.0903181508030.10154@qirst.com> <alpine.DEB.1.10.0903191642160.22425@qirst.com> <20090319220641.GC24586@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009, Mel Gorman wrote:

> >
> >  extern int nr_node_ids;
> > +extern int nr_online_nodes;
> > +extern int nr_possible_nodes;
>
> Have you tested the nr_possible_nodes aspects  of this patch? I can see
> where it gets initialised but nothing that updates it. It would appear that
> nr_possible_nodes() and num_possible_nodes() can return different values.

Right now we bypass the helper functions.... The only places where the
possible map is modified are:

./arch/x86/mm/numa_64.c:        node_set(0, node_possible_map);
./arch/x86/mm/k8topology_64.c:          node_set(nodeid, node_possible_map);
./arch/x86/mm/srat_64.c:        node_possible_map = nodes_parsed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
