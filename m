Date: Mon, 27 Aug 2007 23:12:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
Message-Id: <20070827231214.99e3c33f.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	<1188248528.5952.95.camel@localhost>
	<20070827170159.0a79529d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
	<20070827181405.57a3d8fe.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
	<20070827201822.2506b888.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
	<20070827222912.8b364352.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 22:53:15 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 27 Aug 2007, Andrew Morton wrote:
> 
> > Your claim here is, I believe, that a human user interface should be
> > implemented in the kernel because the cost (to you) (short-term) of doing
> > that is lower that the cost of implementing a simpler kernel interface and
> > a bit of userspace human presentation code.  Even though the long-term
> > cost to the kernel maintainers is higher, and the resulting output is
> > harder for programs to parse.
> 
> The long term cost is zero since there is already a kernel function 
> to process these lists. See bitmap_parselist(). The kernel already allows 
> output and input of these lists.

yeah, I noticed.

Just step back from this for a minute, and think how utterly lame that is. 
User interface code in the kernel because we (actually you guys) have not
expended the tiny amount of effort and initiative which would be required
to develop a little utility to do it.

> > Please type "cat /proc/stat".  The world hasn't ended.
> 
> Yea that the prime example of a bad use of the proc filesystem. All these 
> numbers better be split up into individual files.

Wrong!  My point is that this incomprehensible format is not a problem to
anyone because others have put the effort and initiative into preparation
of tools which present that information to users.

> The cpu affinity is a horror to see on 4096 cpu systems. If you 
> want to figure out to which cpu the process has restricted itself then you 
> need to do some quick hex conversions in your mind.

wtf?  You meen nobody has written the teeny bit of code which is needed to
convert that info into your desired format?

Well that's your problem.  It certainly is not an argument that this user
interface code should be placed in the kernel.

> > > Well I keep ending up cat this and that proc entry for debugging and its 
> > > difficult to do if one sysfs file spews huge amounts of illegible binary 
> > > data to you.
> > 
> > Nobody ever said "binary".  Please try to keep up.
> 
> What you get right now from this patch is a series of hex digits and you 
> have the task of converting that to a series of 0 and 1's in your mind and 
> then figure out which node it was that had a 1 there.

Dude, that problem sounds like a google job interview question.  For
hardware engineers ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
