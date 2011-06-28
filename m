Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BB5FE6B00F1
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:10:58 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p5SLAoXb018686
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 14:10:50 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq7.eem.corp.google.com with ESMTP id p5SLAATF002366
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 14:10:49 -0700
Received: by pwi5 with SMTP id 5so461730pwi.4
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 14:10:44 -0700 (PDT)
Date: Tue, 28 Jun 2011 14:10:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <4E0A41CB.1020908@candelatech.com>
Message-ID: <alpine.DEB.2.00.1106281405000.4229@chino.kir.corp.google.com>
References: <20110626193918.GA3339@joi.lan> <alpine.DEB.2.00.1106281431370.27518@router.home> <4E0A2E26.5000001@gmail.com> <alpine.DEB.2.00.1106281355010.4229@chino.kir.corp.google.com> <4E0A41CB.1020908@candelatech.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Greear <greearb@candelatech.com>
Cc: David Daney <ddaney.cavm@gmail.com>, Christoph Lameter <cl@linux.com>, Marcin Slusarz <marcin.slusarz@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 28 Jun 2011, Ben Greear wrote:

> > SLUB debugging is useful only to diagnose issues or test new code, nobody
> > is going to be enabling it in production environment.  We don't need 30
> > new lines of code that make one thing slightly faster, in fact we'd prefer
> > to have as simple and minimal code as possible for debugging features
> > unless you're adding more debugging coverage.
> 
> If your problem happens under load, then the overhead of slub could
> significantly
> change the behaviour of the system.

You're talking about slub debugging and not slub in general, I assume.

> Anything that makes it more efficient
> without
> unduly complicating code should be a win.  That posted patch wasn't all that
> complicated, and even if it has bugs, it could be fixed easily enough.
> 

"Even if it has bugs"?  Ask Pekka to merge this and be on the receiving 
end of every other kernel development's flames when slub debugging no 
longer finds their problems but instead has bugs of its own.

Again, we want simple and minimal slub debugging code unless you're adding 
a new feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
