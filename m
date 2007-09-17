Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <Pine.LNX.4.64.0709171118160.27048@schroedinger.engr.sgi.com>
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
	 <Pine.LNX.4.64.0709171118160.27048@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 21:14:56 +0100
Message-Id: <1190060096.29967.4.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 11:19 -0700, Christoph Lameter wrote:
> On Mon, 17 Sep 2007, Christoph Lameter wrote:
> 
> > On Sun, 16 Sep 2007, Mel Gorman wrote:
> > 
> > > It increases the size on 32 bit NUMA which we've established is not
> > > confined to the NUMAQ. I think it's best to evaluate adding the node
> > > separetly at a later time.
> > 
> > Na... 32 bit NUMA is not that important.
> > 
> 
> Oh and another thing: If you make both the node and the zoneid unsigned 
> short then there is no loss. zoneid is always < 4 and node is always < 
> 1024. We even could make the zoneid u8 and stuff some more stuff into the 
> list.
> 

ok, that is a very good point. When -mm is settled and one-zonelist in
it's v7 incarnation has been merged, I'll roll a patch that does this
and go through another test cycle. Lee's testing has passed one-zonelist
in it's current incarnation and this close, I don't want to do more
revisions. The patch to do this will be very small so should be easy to
review in isolation. Sound like a plan?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
