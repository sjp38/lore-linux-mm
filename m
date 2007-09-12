Date: Wed, 12 Sep 2007 15:17:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <1189527657.5036.35.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1189527657.5036.35.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Sep 2007, Lee Schermerhorn wrote:

> Andi, Christoph, Mel [added to cc]:
> 
> Any comments on these patches, posted 30aug?  I've rebased to
> 23-rc4-mm1, but before reposting, I wanted to give you a chance to
> comment.

Sorry that it took some time but I only just got around to look at them. 
The one patch that I acked may be of higher priority and should probably 
go in immediately to be merged for 2.6.24.

> I'm going to add Mel's "one zonelist" series to my mempolicy tree with
> these patches and see how that goes.  I'll slide Mel's patches in below
> these, as it looks like they're closer to acceptance into -mm.

That patchset will have a significant impact on yours. You may be able to 
get rid of some of the switch statements. It would be great if we had some 
description as to where you are heading with the incremental changes to 
the memory policy semantics? I sure wish we would have something more 
consistent and easier to understand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
