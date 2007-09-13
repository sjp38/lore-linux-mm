Date: Thu, 13 Sep 2007 11:21:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 3/5] Mem Policy:  MPOL_PREFERRED fixups for "local
 allocation"
In-Reply-To: <1189690525.5013.22.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709131120470.9378@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <20070830185114.22619.61260.sendpatchset@localhost>
 <Pine.LNX.4.64.0709121502420.3835@schroedinger.engr.sgi.com>
 <1189690525.5013.22.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Lee Schermerhorn wrote:

> > Hmmm. But one wants mpol_to_str to represent the memory policy not the 
> > context information that may change through migration. What you 
> > do there is provide information from the context. You could add the 
> > nodemask but I think we need to have some indicator that this policy is 
> > referring to the local policy.
> 
> True.  I could make mpol_to_str return something like "*" for the
> nodemask and document this as "any allowed".

Or print (any) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
