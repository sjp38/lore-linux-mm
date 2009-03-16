Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D72BD6B005D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:53:38 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F2DE13048C5
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:59:48 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fH8L4kBfiskh for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:59:44 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B08FC304941
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:56:42 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:47:35 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for
 num_online_nodes()
In-Reply-To: <20090316163626.GJ24293@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161247170.17730@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161207500.32577@qirst.com> <20090316163626.GJ24293@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> On Mon, Mar 16, 2009 at 12:08:25PM -0400, Christoph Lameter wrote:
> > On Mon, 16 Mar 2009, Mel Gorman wrote:
> >
> > > +extern int static_num_online_nodes;
> >
> > Strange name. Could we name this nr_online_nodes or so?
> >
>
> It's to match the function name. Arguably I could also have replaced the
> implementation of num_online_nodes() with a version that uses the static
> variable.

We have nr_node_ids etc. It would be consistant with that naming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
