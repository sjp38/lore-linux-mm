Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EDB686B009C
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 13:26:02 -0400 (EDT)
Date: Sat, 3 Oct 2009 10:25:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/10] hugetlb:  factor init_nodemask_of_node
Message-Id: <20091003102554.8813e5a6.akpm@linux-foundation.org>
In-Reply-To: <1254483510.7951.24.camel@useless.americas.hpqcorp.net>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
	<20091001165825.32248.75849.sendpatchset@localhost.localdomain>
	<20091002094817.GL21906@csn.ul.ie>
	<1254483510.7951.24.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 02 Oct 2009 07:38:30 -0400 Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> > > +}
> > 
> > Same for mask and node here. Not world ending by any measure.
> 
> Sorry.  Incomplete transformation from macro to function :(
> 
> I'll send out incremental fixes to this and the other botched merge that
> you pointed out in patch 4/10.  Or I can send out replacement patches.
> 
> Andrew:  what's your preference?

I'm easy.  Little fixes would be preferable after the patches have been
merged, so people can see what was changed.  At this stage a full
resend would be OK by my too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
