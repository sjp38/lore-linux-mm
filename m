Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4686002AD
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 11:02:58 -0500 (EST)
Date: Fri, 19 Feb 2010 08:02:39 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 10/12] Add /sys trigger for per-node memory compaction
Message-ID: <20100219160239.GB15619@kroah.com>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
 <1266516162-14154-11-git-send-email-mel@csn.ul.ie>
 <20100219145358.GB24790@kroah.com>
 <20100219152830.GB1445@csn.ul.ie>
 <20100219153142.GA26557@kroah.com>
 <20100219155117.GC1445@csn.ul.ie>
 <20100219155213.GD1445@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100219155213.GD1445@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 03:52:13PM +0000, Mel Gorman wrote:
> On Fri, Feb 19, 2010 at 03:51:17PM +0000, Mel Gorman wrote:
> > On Fri, Feb 19, 2010 at 07:31:42AM -0800, Greg KH wrote:
> > > On Fri, Feb 19, 2010 at 03:28:30PM +0000, Mel Gorman wrote:
> > > > On Fri, Feb 19, 2010 at 06:53:59AM -0800, Greg KH wrote:
> > > > > On Thu, Feb 18, 2010 at 06:02:40PM +0000, Mel Gorman wrote:
> > > > > > This patch adds a per-node sysfs file called compact. When the file is
> > > > > > written to, each zone in that node is compacted. The intention that this
> > > > > > would be used by something like a job scheduler in a batch system before
> > > > > > a job starts so that the job can allocate the maximum number of
> > > > > > hugepages without significant start-up cost.
> > > > > 
> > > > > As you are adding sysfs files, can you please also add documentation for
> > > > > the file in Documentation/ABI/ ?
> > > > > 
> > > > 
> > > > I looked at this before and hit a wall and then forgot about it. I couldn't
> > > > find *where* I should document it at the time. There isn't a sysfs-devices-node
> > > > file to add to and much (all?) of what is in that branch appears undocumented.
> > > 
> > > Well, you can always just document what you add, or you can document the
> > > existing stuff as well.  It's your choice :)
> > > 
> > 
> > Fair point!
> > 
> > I've taken note to document what's in there over time. For the moment,
> > is this a reasonable start? I'll split it into two patches but the end
> > result will be the same.
> > 
> 
> Bah, as I hit send, I recognised my folly. The first entry should be in
> stable/ and the second should be in testing/.
> 

Heh, no problem, looks good to me, thanks for doing this.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
