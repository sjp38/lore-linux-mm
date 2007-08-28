Date: Mon, 27 Aug 2007 22:15:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
In-Reply-To: <20070827201822.2506b888.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188248528.5952.95.camel@localhost> <20070827170159.0a79529d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
 <20070827201822.2506b888.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> > The masks can get quite ugly to read if you have lots of nodes. F.e. with 
> > 1024 nodes you get a line that wraps around more than 10 times.
> 
> So don't read them - use a program to turn them into your preferred
> human-readable representation.

You are volunterring to write all the programs we need for this and that 
debugging situation? Even if you do this: It will significantly slow us 
down always having to come to you and ask you for a tool.

> We see this often, btw.  People want nice and easy-to-read kernel->human
> interfaces because the tool of choice for displaying these things to humans
> is "cat".  How lame is that?
> 
> I do think that a sysfs interface like this should be optimised for
> kernel->program communication, not for kernel->human.

Well I keep ending up cat this and that proc entry for debugging and its 
difficult to do if one sysfs file spews huge amounts of illegible binary 
data to you.

I do not think that tools would have trouble deciphering that format. It 
is going to be more compact and easier to handle to have the node ranges 
rather than converting a list of binaries. Lee already noted the 
huge amounts of zeros that he got.

> > > OK, well if the meminfo file is the only one in there which broke the
> > > golden rule, I don't think we have sufficient excuse to break it again.
> > > 
> > > $ cat  /sys/devices/system/node/possible
> > > 0-4
> > > $
> > > 
> > > I think a bitmap would be better, personally.
> > > 
> > > That in fact makes "possible" unneeded, doesn't it?  It would always be
> > > all-ones?
> > 
> > There could be the case that nodes 1-9 and 20-29 are possible but 
> > the ones in between are not available.
> 
> OK.
> 
> How do we communicate to userspace what is the maximum number of nodes
> which this kernel supports?  That would be (1<<CONFIG_NODES_SHIFT), I
> guess.  Or maybe we don't care?

The last node mentioned in possible is the highest. That will be difficult 
to see if you want the kernel developers to read binary numbers but I 
guess we have to be tough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
