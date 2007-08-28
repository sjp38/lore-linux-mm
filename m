Date: Mon, 27 Aug 2007 22:29:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
Message-Id: <20070827222912.8b364352.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	<1188248528.5952.95.camel@localhost>
	<20070827170159.0a79529d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
	<20070827181405.57a3d8fe.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
	<20070827201822.2506b888.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 22:15:23 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 27 Aug 2007, Andrew Morton wrote:
> 
> > > The masks can get quite ugly to read if you have lots of nodes. F.e. with 
> > > 1024 nodes you get a line that wraps around more than 10 times.
> > 
> > So don't read them - use a program to turn them into your preferred
> > human-readable representation.
> 
> You are volunterring to write all the programs we need for this and that 
> debugging situation?

Sure!  $500/hour!

>  Even if you do this: It will significantly slow us 
> down always having to come to you and ask you for a tool.

Your claim here is, I believe, that a human user interface should be
implemented in the kernel because the cost (to you) (short-term) of doing
that is lower that the cost of implementing a simpler kernel interface and
a bit of userspace human presentation code.  Even though the long-term
cost to the kernel maintainers is higher, and the resulting output is
harder for programs to parse.

Interesting.

Please type "cat /proc/stat".  The world hasn't ended.

> > We see this often, btw.  People want nice and easy-to-read kernel->human
> > interfaces because the tool of choice for displaying these things to humans
> > is "cat".  How lame is that?
> > 
> > I do think that a sysfs interface like this should be optimised for
> > kernel->program communication, not for kernel->human.
> 
> Well I keep ending up cat this and that proc entry for debugging and its 
> difficult to do if one sysfs file spews huge amounts of illegible binary 
> data to you.

Nobody ever said "binary".  Please try to keep up.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
