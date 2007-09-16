Date: Sun, 16 Sep 2007 19:02:10 +0100
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
Message-ID: <20070916180210.GA15184@skynet.ie>
References: <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com> <1189691837.5013.43.camel@localhost> <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com> <20070913182344.GB23752@skynet.ie> <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com> <20070913141704.4623ac57.akpm@linux-foundation.org> <20070914085335.GA30407@skynet.ie> <1189782414.5315.36.camel@localhost> <1189791967.13629.24.camel@localhost> <Pine.LNX.4.64.0709141137090.16964@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709141137090.16964@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On (14/09/07 11:41), Christoph Lameter didst pronounce:
> Since you are going to rework the one zonelist patch again anyway

I only intend to rework the patches again if there is a known problem
with them. In this case, that means that Lee finds a functional problem
or a performance problem is found.

> I would 
> suggest to either use Kame-san full approach and include the node in the 
> zonelist item structure (it does not add any memory since the struct is 
> word aligned and this is an int)

It increases the size on 32 bit NUMA which we've established is not
confined to the NUMAQ. I think it's best to evaluate adding the node
separetly at a later time.

> or go back to the earlier approach of 
> packing the zone id into the low bits which would reduce the cache 
> footprint.
> 

If adding the node does not work out, I will re-evaluate this approach.

> Kame-san's approach is likely very useful if we have a lot of nodes and 
> need to match a nodemask to a zonelist.
> 

I agree but I don't have the tools to prove it yet.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
