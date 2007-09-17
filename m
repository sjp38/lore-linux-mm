Date: Mon, 17 Sep 2007 12:16:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <1190060096.29967.4.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709171215460.27769@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
 <1189691837.5013.43.camel@localhost>  <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
  <20070913182344.GB23752@skynet.ie>  <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
  <20070913141704.4623ac57.akpm@linux-foundation.org>  <20070914085335.GA30407@skynet.ie>
 <1189782414.5315.36.camel@localhost>  <1189791967.13629.24.camel@localhost>
  <Pine.LNX.4.64.0709141137090.16964@schroedinger.engr.sgi.com>
 <20070916180210.GA15184@skynet.ie>  <Pine.LNX.4.64.0709171112010.26860@schroedinger.engr.sgi.com>
  <Pine.LNX.4.64.0709171118160.27048@schroedinger.engr.sgi.com>
 <1190060096.29967.4.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Mel Gorman <mel@skynet.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007, Mel Gorman wrote:

> ok, that is a very good point. When -mm is settled and one-zonelist in
> it's v7 incarnation has been merged, I'll roll a patch that does this
> and go through another test cycle. Lee's testing has passed one-zonelist
> in it's current incarnation and this close, I don't want to do more
> revisions. The patch to do this will be very small so should be easy to
> review in isolation. Sound like a plan?

Yeah. Adding patches on top of your patches sounds great and will give 
Andrew the stability he needs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
