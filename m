From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
Date: Tue, 31 Jul 2007 00:35:08 +0200
References: <20070727194316.18614.36380.sendpatchset@localhost> <20070730211937.GD5668@us.ibm.com> <Pine.LNX.4.64.0707301503560.21604@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707301503560.21604@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707310035.09046.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> Hmmm... yes trouble with NUMAQ is that the nodes only have HIGHMEM 
> but no NORMAL memory. The memory is not available to the slab allocator 
> (needs ZONE_NORMAL memory) and we cannot fall back anymore. We may need 
> something like N_SLAB that defines the allowed nodes for the slab 
> allocators. Sigh.

Or just disable 32bit NUMA. The arch/i386 numa code is beyond ugly anyways
and I don't think it ever worked particularly well.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
