Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB4KOXkS016705
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 15:24:33 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB4KOR73225370
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 13:24:29 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB4KOQsJ004695
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 13:24:26 -0700
Subject: Re: [RFC PATCH] LTTng instrumentation mm (updated)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071204200558.GB1988@Krystal>
References: <20071129023421.GA711@Krystal>
	 <1196317552.18851.47.camel@localhost> <20071130161155.GA29634@Krystal>
	 <1196444801.18851.127.camel@localhost> <20071130170516.GA31586@Krystal>
	 <1196448122.19681.16.camel@localhost> <20071130191006.GB3955@Krystal>
	 <y0mve7ez2y3.fsf@ton.toronto.redhat.com> <20071204192537.GC31752@Krystal>
	 <1196797259.6073.17.camel@localhost>  <20071204200558.GB1988@Krystal>
Content-Type: text/plain
Date: Tue, 04 Dec 2007 12:24:23 -0800
Message-Id: <1196799863.6073.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: "Frank Ch. Eigler" <fche@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-12-04 at 15:05 -0500, Mathieu Desnoyers wrote:
> * Dave Hansen (haveblue@us.ibm.com) wrote:
> > On Tue, 2007-12-04 at 14:25 -0500, Mathieu Desnoyers wrote:
> > > 
> > > - I also dump the equivalent of /proc/swaps (with kernel internal
> > >   information) at trace start to know what swap files are currently
> > >   used.
> > 
> > What about just enhancing /proc/swaps so that this information can be
> > useful to people other than those doing traces?
> 
> It includes an in-kernel struct file pointer, exporting it to userspace
> would be somewhat ugly.

What about just exporting the 'type' field that we use to index into
swap_info[]?

As far as /proc goes, it may not be _ideal_ for your traces, but it sure
beats not getting the information out at all. ;)  I guess I'm just not
that familiar with the tracing requirements and I can't really assess
whether what you're asking for is reasonable, or horrible
over-engineering.  Dunno.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
