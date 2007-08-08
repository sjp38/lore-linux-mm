Date: Wed, 8 Aug 2007 10:03:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when
 highest zone is ZONE_MOVABLE
In-Reply-To: <20070808164944.GA974@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708081002470.12640@schroedinger.engr.sgi.com>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de>
 <20070806121558.e1977ba5.akpm@linux-foundation.org> <200708062231.49247.ak@suse.de>
 <20070806215541.GC6142@skynet.ie> <20070806221252.aa1e9048.akpm@linux-foundation.org>
 <20070807165546.GA7603@skynet.ie> <20070807111430.f35c03c0.akpm@linux-foundation.org>
 <20070808164944.GA974@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Mel Gorman wrote:

> Despite a fairly specific case, I'd still like to get the problem fixed
> for 2.6.23. I've posted up an alternative fix under the subject "Use one
> zonelist per node instead of multiple zonelists v2". It's a more invasive
> fix although arguably it's better overall than the hack because it's not
> dealing with a specific special case and has a sensible path forward that
> makes policies a saner ultimately. However, unlike the hack it affects all
> callers of the page allocator so lets see what the reaction from reviewers
> is before forgetting about the hack altogether.

Well its more a precursor to things to come than a hack. If the tests go 
well for the single zonelist scheme then we may end up doing what the 
patch did for the mpol_bind zonelists for all allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
