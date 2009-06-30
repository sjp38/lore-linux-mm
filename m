Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8CF2A6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:21:53 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4C8EE82C4DC
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:40:07 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EFKpVthbXWjj for <linux-mm@kvack.org>;
	Tue, 30 Jun 2009 10:40:07 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2E4CC82C557
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:39:10 -0400 (EDT)
Date: Tue, 30 Jun 2009 10:21:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: + memory-hotplug-update-zone-pcp-at-memory-online.patch added
 to -mm tree
In-Reply-To: <20090630005828.GC21254@sli10-desk.sh.intel.com>
Message-ID: <alpine.DEB.1.10.0906301020420.6124@gentwo.org>
References: <200906291949.n5TJno8X028680@imap1.linux-foundation.org> <alpine.DEB.1.10.0906291814150.21956@gentwo.org> <20090630005828.GC21254@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Zhao, Yakui" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009, Shaohua Li wrote:

> > foreach possible cpu?
> Just follows zone_pcp_init(), do you think we should change that too?

I plan to change that but for now this would be okay.

> > > +		struct per_cpu_pageset *pset;
> > > +		struct per_cpu_pages *pcp;
> > > +
> > > +		pset = zone_pcp(zone, cpu);
> > > +		pcp = &pset->pcp;
> > > +
> > > +		local_irq_save(flags);
> > > +		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> >
> > There are no pages in the pageset since the pcp batch is zero right?
> It might not be zero for a populated zone, see above comments.

But you are populating an unpopulated zone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
