Date: Thu, 13 Sep 2007 19:23:45 +0100
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
Message-ID: <20070913182344.GB23752@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost> <1189527657.5036.35.camel@localhost> <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com> <1189691837.5013.43.camel@localhost> <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (13/09/07 11:19), Christoph Lameter didst pronounce:
> On Thu, 13 Sep 2007, Lee Schermerhorn wrote:
> 
> > Do we think Mel's patches will make .24?
> 
> No,
> 

What do you see holding it up? Is it the fact we are no longer doing the
pointer packing and you don't want that structure to exist, or is it simply
a case that 2.6.23 is too close the door and it won't get adequate
coverage in -mm?

> <snip>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
