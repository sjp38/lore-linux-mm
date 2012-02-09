Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C5FE16B13F2
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:37:39 -0500 (EST)
Received: by qauh8 with SMTP id h8so1297348qau.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 07:37:38 -0800 (PST)
Date: Thu, 9 Feb 2012 16:37:33 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120209153730.GC22552@somewhere.redhat.com>
References: <20120201184045.GG2382@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202011404500.2074@router.home>
 <20120201201336.GI2382@linux.vnet.ibm.com>
 <4F2A58A1.90800@redhat.com>
 <20120202153437.GD2518@linux.vnet.ibm.com>
 <4F2AB66C.2030309@redhat.com>
 <20120202170134.GM2518@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202021124520.6338@router.home>
 <CAOtvUMdCZpQuSvutKHpMxthktTm_VkA1R99yxpNhxpsYN9wTRQ@mail.gmail.com>
 <alpine.DEB.2.00.1202061218420.2799@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202061218420.2799@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Mon, Feb 06, 2012 at 12:19:44PM -0600, Christoph Lameter wrote:
> On Sun, 5 Feb 2012, Gilad Ben-Yossef wrote
> 
> >
> > Frederic has the latest version in a git tree here:
> >
> > git://github.com/fweisbec/linux-dynticks.git
> >        nohz/cpuset-v2-pre-20120117
> >
> > It's on top latest rcu/core.
> 
> Hmmm.. A pull vs upstream leads to lots of conflicts.

Yeah it's based on the latest rcu/core branch that was pulled
on last -rc1. Better git checkout it than pull.

 
> 
> > But the good news is that with these hacks applied I managed to run a 100%
> > CPU task  with  zero interrupts  (ticks or  otherwise) on an isolated cpu.
> 
> Cool.
> 
> > Disregarding TLB overhead, you get bare metal performance with Linux user
> > space manageability and  debug capabilities.  Pretty magical really: It's like
> > eating your cake and having it too :-)
> 
> We definitely need that.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
