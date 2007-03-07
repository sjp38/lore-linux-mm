Date: Wed, 7 Mar 2007 11:44:35 -0800
From: Mark Gross <mgross@linux.intel.com>
Subject: Re: [RFC} memory unplug patchset prep [0/16]
Message-ID: <20070307194435.GA5158@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0703060145570.22477@chino.kir.corp.google.com> <20070307112450.b7917dcc.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0703061828060.13164@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703061828060.13164@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 06:31:35PM -0800, David Rientjes wrote:
> On Wed, 7 Mar 2007, KAMEZAWA Hiroyuki wrote:
> 
> > > Are you aiming to target both ia64 and x86_64 with this patchset or are 
> > > you focusing on ia64 exclusively at the moment?
> > > 
> > Just because a machine, which I can use as much as I want, is ia64.
> > I don't have x86_64 now. I'll add i386 in the next post.
> > I think all arch which support MEMORY_HOTPLUG will support unplug at last.
> > 
> 
> Ok, sounds good.  I can offer quite extensive x86_64 testing coverage.  I 
> think it's going to be much better to base this patchset on 2.6.21-rc2-mm2 
> so we don't have a couple different GFP_MOVABLE implementations floating 
> around.
> 
> I'll await your next patchset and then I'll play around with it for 
> x86_64.  I'd like to eventually combine your memory unplug work with Mark 
> Gross's PM-memory enabling node flags (cc'd).  We can wire it up through a 
> sysfs interface for userspace manipulation and see it working in action.
> 
> Looking forward to the next series.

Me too!

--mgross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
