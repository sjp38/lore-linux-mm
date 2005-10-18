Date: Tue, 18 Oct 2005 09:54:02 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 0/2] Page migration via Swap V2: Overview
In-Reply-To: <20051018121642.GA13963@logos.cnet>
Message-ID: <Pine.LNX.4.62.0510180951050.7911@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
 <20051018121642.GA13963@logos.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, ak@suse.de, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 18 Oct 2005, Marcelo Tosatti wrote:

> Having a duplicate implementation is somewhat disappointing - why not fix the problems
> with real page migration?

There are problems on a variety of levels. Its just too complicated to 
work them out in one go. I think we would need much more support from the 
larger developer community to get there. With a simple working migration 
approach we can simultaneously:

1. Explore solutions to the lower level migration code

2. Deal with the memory policy issues arising in hotplug and in memory 
migration. These are masked by the swap based migration because swapin 
guarantees the correct use of memory policies and cpuset restrictions.

3. Implement appropriate higher level control of page migration via a 
variety of methods and develop the necessary user land support structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
