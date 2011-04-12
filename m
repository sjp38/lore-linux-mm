Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D20DB8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:27:27 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3C28HDf021929
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:08:17 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 56EB138C803E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:27:16 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3C2RP8Q353676
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:27:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3C2RODd009483
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:27:25 -0400
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110412100129.43F1.A69D9226@jp.fujitsu.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com>
	 <1302557371.7286.16607.camel@nimitz>
	 <20110412100129.43F1.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 11 Apr 2011 19:27:21 -0700
Message-ID: <1302575241.7286.17853.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Tue, 2011-04-12 at 10:01 +0900, KOSAKI Motohiro wrote:
> > On Mon, 2011-04-11 at 17:19 +0900, KOSAKI Motohiro wrote:
> > > This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> > > specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> > > relatively cheap 2-4 socket machine are often used for tradiotional
> > > server as above. The intention is, their machine don't use
> > > zone_reclaim_mode.
> > 
> > I know specifically of pieces of x86 hardware that set the information
> > in the BIOS to '21' *specifically* so they'll get the zone_reclaim_mode
> > behavior which that implies.
> 
> Which hardware?

I'd have to go digging for the model numbers.  I just remember having
discussions with folks about it a couple of years ago.  My memory isn't
what it used to be. :)

> The reason why now we decided to change default is the original bug reporter was using
> mere commodity whitebox hardware and very common workload. 
> If it is enough commotidy, we have to concern it. but if it is special, we don't care it.
> Hardware vendor should fix a firmware.

Yeah, it's certainly a "simple" fix.  The distance tables can certainly
be adjusted easily, and worked around pretty trivially with boot
options.  If we decide to change the generic case, let's also make sure
that we put something else in place simultaneously that is nice for the
folks that don't want it changed.  Maybe something DMI-based that digs
for model numbers?

I'll go try and dig for some more specifics on the hardware so we at
least have something to test on.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
