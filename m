Date: Thu, 13 Sep 2007 11:26:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
In-Reply-To: <20070913182344.GB23752@skynet.ie>
Message-ID: <Pine.LNX.4.64.0709131124100.9378@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1189527657.5036.35.camel@localhost> <Pine.LNX.4.64.0709121515210.3835@schroedinger.engr.sgi.com>
 <1189691837.5013.43.camel@localhost> <Pine.LNX.4.64.0709131118190.9378@schroedinger.engr.sgi.com>
 <20070913182344.GB23752@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Mel Gorman wrote:

> What do you see holding it up? Is it the fact we are no longer doing the
> pointer packing and you don't want that structure to exist, or is it simply
> a case that 2.6.23 is too close the door and it won't get adequate
> coverage in -mm?

No its not the pointer packing. The problem is that the patches have not 
been merged yet and 2.6.23 is close. We would need to merge it very soon 
and get some exposure in mm. Andrew?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
