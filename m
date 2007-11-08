Date: Thu, 8 Nov 2007 18:39:30 +0000
Subject: Re: Plans for Onezonelist patch series ???
Message-ID: <20071108183930.GB23882@skynet.ie>
References: <20071107011130.382244340@sgi.com> <1194535612.6214.9.camel@localhost> <1194537674.5295.8.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1194537674.5295.8.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/11/07 11:01), Lee Schermerhorn didst pronounce:
> Mel [anyone?]
> 
> Do you know what the plans are for your "onezonelist" patch series?
> 

I was holding off trying to add new features to current mainline or -mm as
there were a number of stability issues and one-zonelist touches a number
of areas.  Minimally, I was waiting for another -mm to come out and rebase
to that.  I'll rebase to latest git tomorrow, see how that looks and post
it if passes regression tests on Monday.

> Are they going into -mm for, maybe, .25?  Or have they been dropped.  
> 
> I carry the last posting in my mempolicy tree--sometimes below my
> patches; sometimes above.  Our patches touch some of the same places in
> mempolicy.c and require reject resolution when changing the order.  I
> can save Andrew some work if I knew that your patches were going to be
> in the next -mm by holding off and doing the rebase myself.
> 

The one-zonelist stuff is likely to be more controversial than what you
are doing. It may be best if the one-zonelist patches are based on top
of yours than the other way around.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
