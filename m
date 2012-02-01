Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id B1E676B13F1
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 15:13:57 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 1 Feb 2012 13:13:56 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E832E3E40048
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 13:13:45 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q11KDdHp159612
	for <linux-mm@kvack.org>; Wed, 1 Feb 2012 13:13:41 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q11KDbVg015744
	for <linux-mm@kvack.org>; Wed, 1 Feb 2012 13:13:39 -0700
Date: Wed, 1 Feb 2012 12:13:36 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120201201336.GI2382@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
 <1327591185.2446.102.camel@twins>
 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
 <1328117722.2446.262.camel@twins>
 <20120201184045.GG2382@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202011404500.2074@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202011404500.2074@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Wed, Feb 01, 2012 at 02:06:07PM -0600, Christoph Lameter wrote:
> On Wed, 1 Feb 2012, Paul E. McKenney wrote:
> 
> > On Wed, Feb 01, 2012 at 06:35:22PM +0100, Peter Zijlstra wrote:
> > > On Sun, 2012-01-29 at 10:25 +0200, Gilad Ben-Yossef wrote:
> > > >
> > > > If this is of interest, I keep a list tracking global IPI and global
> > > > task schedulers sources in the core kernel here:
> > > > https://github.com/gby/linux/wiki.
> > >
> > > You can add synchronize_.*_expedited() to the list, it does its best to
> > > bash the entire machine in order to try and make RCU grace periods
> > > happen fast.
> >
> > I have duly added "Make synchronize_sched_expedited() avoid IPIing idle
> > CPUs" to http://kernel.org/pub/linux/kernel/people/paulmck/rcutodo.html.
> >
> > This should not be hard once I have built up some trust in the new
> > RCU idle-detection code.  It would also automatically apply to
> > Frederic's dyntick-idle userspace work.
> 
> Could we also apply the same approach to processors busy doing
> computational work? In that case the OS is also not needed. Interrupting
> these activities is impacting on performance and latency.

Yep, that is in fact what Frederic's dyntick-idle userspace work does.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
