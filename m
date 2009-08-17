Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6A9C96B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:29:27 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 89BE982C615
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:29:29 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cMPC655pj-Ze for <linux-mm@kvack.org>;
	Mon, 17 Aug 2009 12:29:29 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8A90F82C7E8
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:29:20 -0400 (EDT)
Date: Mon, 17 Aug 2009 12:29:03 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and
 'slabinfo'
In-Reply-To: <1250502847.5038.16.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0908171228300.16267@gentwo.org>
References: <20090817094525.6355.88682.sendpatchset@localhost.localdomain>  <20090817094822.GA17838@elte.hu> <1250502847.5038.16.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Aug 2009, Pekka Enberg wrote:

> > I have applied the timer_list bits to the timer tree. The SLUB/SLAB
> > bits should go into the SLAB tree i guess.
>
> Yeah, I'll grab the slab parts to slab.git if I don't see a separate
> patch in my inbox when I get home. Thanks!

slab needs the write permissions for tuning!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
