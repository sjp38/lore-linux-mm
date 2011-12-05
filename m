Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C80C86B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 08:15:25 -0500 (EST)
Subject: Re: [PATCH 09/11] slab, lockdep: Fix silly bug
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <alpine.LFD.2.02.1112051503400.8257@tux.localdomain>
References: <20111204185444.411298317@goodmis.org>
	 <20111204190021.812654254@goodmis.org>
	 <alpine.LFD.2.02.1112051503400.8257@tux.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Dec 2011 08:15:20 -0500
Message-ID: <1323090920.30977.72.camel@frodo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-rt-users <linux-rt-users@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Carsten Emde <C.Emde@osadl.org>, John Kacur <jkacur@redhat.com>, stable@kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hans Schillstrom <hans@schillstrom.com>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Mon, 2011-12-05 at 15:04 +0200, Pekka Enberg wrote:

> Your emails seem to be damaged in interesting ways.

Really? I'm using quilt mail to send.

> 
> I assume the patch is going through the lockdep tree? If so, please make 
> sure you include Christoph's ACK in the changelog.

This is for the stable-rt tree. This patch is on its way, but you'll
have to talk to Peter about Acks and such.

But this brings up a point. I'll start adding [RT] to the subject of the
patches as well to not confuse people.

Thanks,

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
