Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD9C56B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 21:10:45 -0400 (EDT)
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.0908141649500.26836@chino.kir.corp.google.com>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
	 <20090729181205.23716.25002.sendpatchset@localhost.localdomain>
	 <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com>
	 <20090731103632.GB28766@csn.ul.ie>
	 <1249067452.4674.235.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.2.00.0908141532510.23204@chino.kir.corp.google.com>
	 <20090814160830.e301d68a.akpm@linux-foundation.org>
	 <alpine.DEB.2.00.0908141649500.26836@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Sun, 16 Aug 2009 21:10:41 -0400
Message-Id: <1250471441.4472.108.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, nacc@us.ibm.com, Andi Kleen <andi@firstfloor.org>, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-08-14 at 16:53 -0700, David Rientjes wrote:
> On Fri, 14 Aug 2009, Andrew Morton wrote:
> 
> > On Fri, 14 Aug 2009 15:38:43 -0700 (PDT)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> > > Andrew, Lee, what's the status of this patchset?
> > 
> > All forgotten about as far as I'm concerned.  It was v1, it had "rfc"
> > in there and had an "Ick, no, please don't do that" from Greg.  I
> > assume Greg's OK with the fixed-up version.
> > 
> > 
> 
> I think Greg's concerns were addressed in the latest revision of the 
> patchset, specifically http://marc.info/?l=linux-mm&m=124906676520398.
> 
> Maybe the more appropriate question to ask is if Mel has any concerns 
> about adding the per-node hstate attributes either as a substitution or as 
> a complement to the mempolicy-based allocation approach.  Mel?
> 
> Lee, do you have plans to resend the patchset including the modified kobj 
> handling?

Yes.  I had planned to ping you and Mel, as I hadn't heard back from you
about the combined interfaces.  I think they mesh fairly well, and the
per node attributes have the, perhaps desirable, property of ignoring
any current task mempolicy.  But, I know that some folks don't like a
proliferation of ways to do something.  I'll package up the series [I
need to update the Documentation for the per node attributes] and send
it out as soon as I can get to it.  This week, I'm pretty sure.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
