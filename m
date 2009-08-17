Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 016DD6B005A
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:41:57 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8939382C26C
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:42:04 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id y9o5Sla+1ZAe for <linux-mm@kvack.org>;
	Mon, 17 Aug 2009 12:42:04 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B18CC82C299
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:41:59 -0400 (EDT)
Date: Mon, 17 Aug 2009 12:41:54 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and
 'slabinfo'
In-Reply-To: <4A8986BB.80409@cs.helsinki.fi>
Message-ID: <alpine.DEB.1.10.0908171240370.16267@gentwo.org>
References: <20090817094525.6355.88682.sendpatchset@localhost.localdomain>  <20090817094822.GA17838@elte.hu> <1250502847.5038.16.camel@penberg-laptop> <alpine.DEB.1.10.0908171228300.16267@gentwo.org> <4A8986BB.80409@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Aug 2009, Pekka Enberg wrote:

> > slab needs the write permissions for tuning!
>
> Oh, crap, you're right, I had forgotten about that. It's probably best to keep
> slub permissions as-is, no?

slub perms can be changed. The patch is okay for that. But there is no
write method in slub. Effectively it makes no difference. Just the
display is nicer in /proc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
