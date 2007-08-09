From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple zonelists v2
Date: Thu, 9 Aug 2007 23:20:01 +0200
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie> <20070809131943.64cb0921.akpm@linux-foundation.org>
In-Reply-To: <20070809131943.64cb0921.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708092320.01669.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Lee.Schermerhorn@hp.com, pj@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 09 August 2007 22:19:43 Andrew Morton wrote:
> On Wed,  8 Aug 2007 17:15:04 +0100 (IST)
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > The following patches replace multiple zonelists per node with one zonelist
> > that is filtered based on the GFP flags.
> 
> I think I'll duck this for now on im-trying-to-vaguely-stabilize-mm grounds.
> Let's go with the horrible-hack for 2.6.23, then revert it and get this
> new approach merged and stabilised over the next week or two?

I would prefer to not have horrible hacks even temporary

-Andi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
