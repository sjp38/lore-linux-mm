Date: Tue, 7 Aug 2007 13:37:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when
 highest zone is ZONE_MOVABLE
In-Reply-To: <20070807111430.f35c03c0.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708071334430.3430@schroedinger.engr.sgi.com>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de>
 <20070806121558.e1977ba5.akpm@linux-foundation.org> <200708062231.49247.ak@suse.de>
 <20070806215541.GC6142@skynet.ie> <20070806221252.aa1e9048.akpm@linux-foundation.org>
 <20070807165546.GA7603@skynet.ie> <20070807111430.f35c03c0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, Andi Kleen <ak@suse.de>, Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2007, Andrew Morton wrote:

> > It's even more constrained than that. It only applies to the MPOL_BIND
> > policy when kernelcore= is specified. The other policies work the same
> > as they ever did.
> 
> so.. should we forget about merging the horrible-hack?

Support MPOL_BIND is a basic NUMA feature. This is going to make .23 
unusable for us if kernelcore= is used. If we cannot use kernelcore then 
NUMA systems cannot use the features that depend on kernelcore.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
