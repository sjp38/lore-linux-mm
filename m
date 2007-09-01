Date: Fri, 31 Aug 2007 17:34:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20070831205319.22283.45590.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708311732580.19868@schroedinger.engr.sgi.com>
References: <20070831205139.22283.71284.sendpatchset@skynet.skynet.ie>
 <20070831205319.22283.45590.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Good idea. That gets rid of the GFP_THISNODE stuff that I introduced for 
the memoryless node patchset.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
