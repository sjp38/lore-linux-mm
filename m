Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 60DAD6B0082
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 11:41:51 -0400 (EDT)
Date: Wed, 30 Sep 2009 16:55:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during resume
Message-ID: <20090930155543.GC17906@csn.ul.ie>
References: <20090915120538.GA26806@bizet.domek.prywatny> <200909170118.53965.rjw@sisk.pl> <4AB29F4A.3030102@intel.com> <200909180027.37387.rjw@sisk.pl> <20090922233531.GA3198@bizet.domek.prywatny> <20090929135810.GB14911@csn.ul.ie> <20090930153730.GA2120@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090930153730.GA2120@bizet.domek.prywatny>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, david.graham@intel.com, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 30, 2009 at 05:37:30PM +0200, Karol Lewandowski wrote:
> On Tue, Sep 29, 2009 at 02:58:11PM +0100, Mel Gorman wrote:
> > On Wed, Sep 23, 2009 at 01:35:31AM +0200, Karol Lewandowski wrote:
> > > Maybe I should revert following commits (chosen somewhat randomly)?
> > > 
> > > 1. 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> > > 
> > > 2. dd5d241ea955006122d76af88af87de73fec25b4 - alters changes made by
> > > commit above
> > > 
> > > Any ideas?
> > > 
> > 
> > Those commits should only make a difference on small-memory machines.
> > The exact value of "small" varies but on 32 bit x86 without PAE, it would
> > be 20MB of RAM. The fact reverting the two patches makes any difference at
> > all is a surprise and likely a co-incidence.
> > 
> > If you have a reliable reproduction case, would it be possible to bisect
> > between the points
> > d239171e4f6efd58d7e423853056b1b6a74f1446..b70d94ee438b3fd9c15c7691d7a932a135c18101
> > to see if the problem is in there anywhere?
> 
> I've started with bc75d33f0 (one commit before d239171e4 in Linus'
> tree) but then my system fails to resume.
> 

Does the bug require a suspend/resume or would something like

rmmod e100
updatedb
modprobe e100

reproduce the problem?

> Whatever I do (change fb/Xorg drivers, disable X, etc.) I always end
> up with unusable display and something that looks like hard-locked
> system (I haven't tested network connectivity from another box, but
> console is surely dead).
> 
> Thanks.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
