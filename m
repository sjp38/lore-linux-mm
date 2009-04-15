Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EED665F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 08:48:18 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DECE182C371
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 08:58:44 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TDJuiuac-qgV for <linux-mm@kvack.org>;
	Wed, 15 Apr 2009 08:58:44 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3651982C3E0
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 08:58:40 -0400 (EDT)
Date: Wed, 15 Apr 2009 08:41:38 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] migration: only migrate_prep() once per move_pages()
In-Reply-To: <49E5A9DC.2050309@inria.fr>
Message-ID: <alpine.DEB.1.10.0904150840450.10217@qirst.com>
References: <49E58D7A.4010708@ens-lyon.org> <20090415164955.41746866.kamezawa.hiroyu@jp.fujitsu.com> <49E5A9DC.2050309@inria.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Apr 2009, Brice Goglin wrote:

> But lru_add_drain_all() touches some code that I am far from
> understanding :/ Can we imagine using IPI instead of a deferred
> work_struct for this kind of things? Or maybe, for each processor, check
> whether drain_cpu_pagevecs() would have something to do before actually
> scheduling the local work_struct? It's racy, but migrate_prep() doesn't
> guarantee anyway that pages won't be moved out of the LRU before the
> actual migration, so...

IPI means that code must run with interrupts disabled.

> > BTW, current users of sys_move_pages() does retry when it gets -EBUSY ?
> >
>
> I'd say they ignore it since it doesn't happen often :)

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
