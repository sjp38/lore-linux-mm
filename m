Message-ID: <486CD623.8030906@linux-foundation.org>
Date: Thu, 03 Jul 2008 08:37:39 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [problem] raid performance loss with 2.6.26-rc8 on 32-bit x86
 (bisected)
References: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com>	 <20080701080910.GA10865@csn.ul.ie> <20080701175855.GI32727@shadowen.org>	 <20080701190741.GB16501@csn.ul.ie>	 <1214944175.26855.18.camel@dwillia2-linux.ch.intel.com>	 <20080702051759.GA26338@csn.ul.ie>	 <1215049766.2840.43.camel@dwillia2-linux.ch.intel.com>	 <20080703042750.GB14614@csn.ul.ie>	 <alpine.LFD.1.10.0807022135360.18105@woody.linux-foundation.org>	 <20080703050036.GD14614@csn.ul.ie> <1215064455.15797.4.camel@dwillia2-linux.ch.intel.com>
In-Reply-To: <1215064455.15797.4.camel@dwillia2-linux.ch.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, lee.schermerhorn@hp.com, a.beregalov@gmail.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

What a convoluted description. Simply put: We clobber the nr_zones field
because we write beyond the bounds of the node_zonelists[] array in
struct pglist_data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
