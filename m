Date: Thu, 13 Sep 2007 11:19:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <1189691837.5013.43.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1189527657.5036.35.camel@localhost>  <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
 <1189691837.5013.43.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Lee Schermerhorn wrote:

> Do we think Mel's patches will make .24?

No,

> > That patchset will have a significant impact on yours. You may be able to 
> > get rid of some of the switch statements. It would be great if we had some 
> > description as to where you are heading with the incremental changes to 
> > the memory policy semantics? I sure wish we would have something more 
> > consistent and easier to understand.
> 
> The general reaction to such descriptions is "show me the code."  So, if
> we agree that Mel's patches should go first, I'll rebase and update the
> numa_memory_policy doc accordingly to explain the resulting semantics.
> Perhaps Mel should considering updating that document where his patches
> change/invalidate the current descriptions.
> 
> Does this sound like a resonable way to proceed?

Well I am not the show me the code type. I'd like to have some 
documentation first on how this would all work together with page 
migration, cpusets and the use of various memory policies. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
