Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 766AA6B004F
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 19:53:21 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n7ENrNpc022951
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 16:53:24 -0700
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by spaceape9.eur.corp.google.com with ESMTP id n7ENrJ5E031405
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 16:53:20 -0700
Received: by pxi14 with SMTP id 14so549773pxi.19
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 16:53:19 -0700 (PDT)
Date: Fri, 14 Aug 2009 16:53:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
In-Reply-To: <20090814160830.e301d68a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.0908141649500.26836@chino.kir.corp.google.com>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain> <20090729181205.23716.25002.sendpatchset@localhost.localdomain> <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com> <20090731103632.GB28766@csn.ul.ie>
 <1249067452.4674.235.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0908141532510.23204@chino.kir.corp.google.com> <20090814160830.e301d68a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, nacc@us.ibm.com, Andi Kleen <andi@firstfloor.org>, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 14 Aug 2009, Andrew Morton wrote:

> On Fri, 14 Aug 2009 15:38:43 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > Andrew, Lee, what's the status of this patchset?
> 
> All forgotten about as far as I'm concerned.  It was v1, it had "rfc"
> in there and had an "Ick, no, please don't do that" from Greg.  I
> assume Greg's OK with the fixed-up version.
> 
> 

I think Greg's concerns were addressed in the latest revision of the 
patchset, specifically http://marc.info/?l=linux-mm&m=124906676520398.

Maybe the more appropriate question to ask is if Mel has any concerns 
about adding the per-node hstate attributes either as a substitution or as 
a complement to the mempolicy-based allocation approach.  Mel?

Lee, do you have plans to resend the patchset including the modified kobj 
handling?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
