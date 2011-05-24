Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A31A46B0025
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:37:09 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4OKH7w4024215
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:17:07 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4OKb77E066382
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:37:07 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4OEb5is009447
	for <linux-mm@kvack.org>; Tue, 24 May 2011 08:37:06 -0600
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110524130700.079b09e8.akpm@linux-foundation.org>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com>
	 <1302557371.7286.16607.camel@nimitz>
	 <20110412100129.43F1.A69D9226@jp.fujitsu.com>
	 <1302575241.7286.17853.camel@nimitz>
	 <20110524130700.079b09e8.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 24 May 2011 13:37:04 -0700
Message-ID: <1306269424.22505.20.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Tue, 2011-05-24 at 13:07 -0700, Andrew Morton wrote:
> On Mon, 11 Apr 2011 19:27:21 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > I'll go try and dig for some more specifics on the hardware so we at
> > least have something to test on.
> 
> How's that digging coming along?
> 
> I'm pretty wobbly about this patch.  Perhaps we should set
> RECLAIM_DISTANCE to pi/2 or something, to force people to correctly set
> the dang thing in initscripts.

The original change in the hardware tables was for the benefit of a
benchmark.  Said benchmark isn't going to get run on mainline until the
next batch of enterprise distros drops, at which point the hardware
where this was done will be irrelevant for the benchmark.  I'm sure any
new hardware will just set this distance to another yet arbitrary value
to make the kernel do what it wants. :)

Also, when the hardware got _set_ to this initially, I complained.  So,
I guess I'm getting my way now, with this patch.  I'm cool with it:

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
