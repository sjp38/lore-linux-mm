Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B22E06B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:07:07 -0400 (EDT)
Date: Tue, 24 May 2011 13:07:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
Message-Id: <20110524130700.079b09e8.akpm@linux-foundation.org>
In-Reply-To: <1302575241.7286.17853.camel@nimitz>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com>
	<1302557371.7286.16607.camel@nimitz>
	<20110412100129.43F1.A69D9226@jp.fujitsu.com>
	<1302575241.7286.17853.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Mon, 11 Apr 2011 19:27:21 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Tue, 2011-04-12 at 10:01 +0900, KOSAKI Motohiro wrote:
> > > On Mon, 2011-04-11 at 17:19 +0900, KOSAKI Motohiro wrote:
> > > > This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> > > > specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> > > > relatively cheap 2-4 socket machine are often used for tradiotional
> > > > server as above. The intention is, their machine don't use
> > > > zone_reclaim_mode.
> > > 
> > > I know specifically of pieces of x86 hardware that set the information
> > > in the BIOS to '21' *specifically* so they'll get the zone_reclaim_mode
> > > behavior which that implies.
> > 
> > Which hardware?
> 
> I'd have to go digging for the model numbers.  I just remember having
> discussions with folks about it a couple of years ago.  My memory isn't
> what it used to be. :)
> 
> > The reason why now we decided to change default is the original bug reporter was using
> > mere commodity whitebox hardware and very common workload. 
> > If it is enough commotidy, we have to concern it. but if it is special, we don't care it.
> > Hardware vendor should fix a firmware.
> 
> Yeah, it's certainly a "simple" fix.  The distance tables can certainly
> be adjusted easily, and worked around pretty trivially with boot
> options.  If we decide to change the generic case, let's also make sure
> that we put something else in place simultaneously that is nice for the
> folks that don't want it changed.  Maybe something DMI-based that digs
> for model numbers?
> 
> I'll go try and dig for some more specifics on the hardware so we at
> least have something to test on.
> 

How's that digging coming along?

I'm pretty wobbly about this patch.  Perhaps we should set
RECLAIM_DISTANCE to pi/2 or something, to force people to correctly set
the dang thing in initscripts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
