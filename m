Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC138D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:26:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2C01E3EE0B5
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:26:01 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1079645DE92
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:26:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB5A545DE95
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:26:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D85BFE18001
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:26:00 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A12E0E08004
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:26:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <1302575241.7286.17853.camel@nimitz>
References: <20110412100129.43F1.A69D9226@jp.fujitsu.com> <1302575241.7286.17853.camel@nimitz>
Message-Id: <20110412162631.B51C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Apr 2011 16:25:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

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

O.K.

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

That pretty makes sense. If you can find exacl model number, I'm fully
assist this portion.


> I'll go try and dig for some more specifics on the hardware so we at
> least have something to test on.

Thank you!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
