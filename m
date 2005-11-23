Date: Wed, 23 Nov 2005 14:01:47 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
In-Reply-To: <20051123115545.69087adf.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0511231356200.23615@schroedinger.engr.sgi.com>
References: <20051122161000.A22430@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0511231128090.22710@schroedinger.engr.sgi.com>
 <1132775194.25086.54.camel@akash.sc.intel.com> <20051123115545.69087adf.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Rohit Seth <rohit.seth@intel.com>, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Nov 2005, Andrew Morton wrote:

> I was able to demonstrate a large (~60%?) speedup in one microbenckmark
> which consisted of four processes writing 16k to a file and truncating it
> back to zero again.  That gain came from the cache warmth effect, which is
> the other benefit which these cpu-local pages are supposed to provide.

Maybe we can cut the pcp logic back to only put cache warm pages into a
single per_cpu pcp list for the local processor that contains node local 
pages? Return all remote pages and cold pages directly to the buddy lists.

That way we can remove the logic to flush remote pages and remove those 
pcp lists for remote nodes that are mostly empty anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
