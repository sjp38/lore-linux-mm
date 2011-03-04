Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1928D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 19:32:59 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p240RfCf001600
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 17:27:41 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p240WpFF104522
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 17:32:51 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p240US5m022331
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 17:30:28 -0700
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1299193700.3062.260.camel@calx>
References: <1299174652.2071.12.camel@dan>  <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan>  <1299188667.3062.259.camel@calx>
	 <1299191400.2071.203.camel@dan>  <1299193700.3062.260.camel@calx>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 03 Mar 2011 16:32:49 -0800
Message-ID: <1299198769.8493.2981.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2011-03-03 at 17:08 -0600, Matt Mackall wrote:
> > I appreciate your input on this, you've made very reasonable points.
> > I'm just not convinced that those few real users are being substantially
> > inconvenienced, even if there's only a small benefit for the larger
> > population of users who are at risk for attacks.  Perhaps others could
> > contribute their opinions to the discussion.


Kees Cook was nice enough to point out a few of the ways this can get
misused.  It looks like the basic pattern is to use slabinfo to
determine where an object was likely to have been allocated in the slab
in order to more precisely target the next stage of the attack.

I do see how much easier slabinfo makes this.  Do any of the attacks
that we know about rely on anything _but_ trying to figure out when a
slab page got consumed?

If I were an attacker, I'd probably just start watching /proc/meminfo
for when Slab/SReclaimable/SUnreclaim get bumped.  That'll also give me
a pretty good indicator of where my object is in the slab.

Granted, doing that still puts one more level of opaqueness in the way.
slabinfo definitely makes it more straightforward.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
