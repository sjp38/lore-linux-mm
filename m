Date: Fri, 14 Sep 2007 11:41:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <1189791967.13629.24.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709141137090.16964@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1189527657.5036.35.camel@localhost>  <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
  <1189691837.5013.43.camel@localhost>  <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
  <20070913182344.GB23752@skynet.ie>  <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
  <20070913141704.4623ac57.akpm@linux-foundation.org>  <20070914085335.GA30407@skynet.ie>
  <1189782414.5315.36.camel@localhost> <1189791967.13629.24.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Since you are going to rework the one zonelist patch again anyway I would 
suggest to either use Kame-san full approach and include the node in the 
zonelist item structure (it does not add any memory since the struct is 
word aligned and this is an int) or go back to the earlier approach of 
packing the zone id into the low bits which would reduce the cache 
footprint.

Kame-san's approach is likely very useful if we have a lot of nodes and 
need to match a nodemask to a zonelist.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
