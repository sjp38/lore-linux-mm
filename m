Date: Thu, 3 Jul 2008 09:46:12 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Do not clobber pgdat->nr_zones during memory
 initialisation
In-Reply-To: <alpine.LFD.1.10.0807030942440.18105@woody.linux-foundation.org>
Message-ID: <alpine.LFD.1.10.0807030944510.18105@woody.linux-foundation.org>
References: <20080701175855.GI32727@shadowen.org> <20080701190741.GB16501@csn.ul.ie> <1214944175.26855.18.camel@dwillia2-linux.ch.intel.com> <20080702051759.GA26338@csn.ul.ie> <1215049766.2840.43.camel@dwillia2-linux.ch.intel.com> <20080703042750.GB14614@csn.ul.ie>
 <alpine.LFD.1.10.0807022135360.18105@woody.linux-foundation.org> <20080703050036.GD14614@csn.ul.ie> <1215064455.15797.4.camel@dwillia2-linux.ch.intel.com> <486CD623.8030906@linux-foundation.org> <20080703163638.GC18055@csn.ul.ie>
 <alpine.LFD.1.10.0807030942440.18105@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, lee.schermerhorn@hp.com, a.beregalov@gmail.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


On Thu, 3 Jul 2008, Linus Torvalds wrote:
>
> So it's now committed as follows..

Side note: master.kernel.org is going through maintenance today, so I 
haven't actually been able to push it out yet, in case anybody wonders why 
it's not showing up on the public sites.

It will all be out there later today.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
