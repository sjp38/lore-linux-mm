Date: Mon, 17 Sep 2007 11:19:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <Pine.LNX.4.64.0709171112010.26860@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0709171118160.27048@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
 <1189691837.5013.43.camel@localhost> <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
 <20070913182344.GB23752@skynet.ie> <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
 <20070913141704.4623ac57.akpm@linux-foundation.org> <20070914085335.GA30407@skynet.ie>
 <1189782414.5315.36.camel@localhost> <1189791967.13629.24.camel@localhost>
 <Pine.LNX.4.64.0709141137090.16964@schroedinger.engr.sgi.com>
 <20070916180210.GA15184@skynet.ie> <Pine.LNX.4.64.0709171112010.26860@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007, Christoph Lameter wrote:

> On Sun, 16 Sep 2007, Mel Gorman wrote:
> 
> > It increases the size on 32 bit NUMA which we've established is not
> > confined to the NUMAQ. I think it's best to evaluate adding the node
> > separetly at a later time.
> 
> Na... 32 bit NUMA is not that important.
> 

Oh and another thing: If you make both the node and the zoneid unsigned 
short then there is no loss. zoneid is always < 4 and node is always < 
1024. We even could make the zoneid u8 and stuff some more stuff into the 
list.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
