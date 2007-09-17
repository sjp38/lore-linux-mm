Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <Pine.LNX.4.64.0709171112010.26860@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
	 <1189691837.5013.43.camel@localhost>
	 <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
	 <20070913182344.GB23752@skynet.ie>
	 <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
	 <20070913141704.4623ac57.akpm@linux-foundation.org>
	 <20070914085335.GA30407@skynet.ie> <1189782414.5315.36.camel@localhost>
	 <1189791967.13629.24.camel@localhost>
	 <Pine.LNX.4.64.0709141137090.16964@schroedinger.engr.sgi.com>
	 <20070916180210.GA15184@skynet.ie>
	 <Pine.LNX.4.64.0709171112010.26860@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 21:03:18 +0100
Message-Id: <1190059398.29967.1.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 11:12 -0700, Christoph Lameter wrote:
> On Sun, 16 Sep 2007, Mel Gorman wrote:
> 
> > It increases the size on 32 bit NUMA which we've established is not
> > confined to the NUMAQ. I think it's best to evaluate adding the node
> > separetly at a later time.
> 
> Na... 32 bit NUMA is not that important.

Paul Mundt might disagree. Later when I revisit the node-id-in-zoneref
issue, I'll be asking him to do a quick performance check if I can't get
a simulator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
