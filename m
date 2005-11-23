Date: Wed, 23 Nov 2005 11:30:10 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
In-Reply-To: <20051122161000.A22430@unix-os.sc.intel.com>
Message-ID: <Pine.LNX.4.62.0511231128090.22710@schroedinger.engr.sgi.com>
References: <20051122161000.A22430@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Nov 2005, Rohit Seth wrote:

> [PATCH]: This patch free pages (pcp->batch from each list at a time) from
> local pcp lists when a higher order allocation request is not able to 
> get serviced from global free_list.

Ummm.. One controversial idea: How about removing the complete pcp 
subsystem? Last time we disabled pcps we saw that the effect 
that it had was within noise ratio on AIM7. The lru lock taken without 
pcp is in the local zone and thus rarely contended.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
