Date: Wed, 11 Jun 2008 12:35:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v4][PATCH 1/2] pass mm into pagewalkers
Message-Id: <20080611123531.9279c104.akpm@linux-foundation.org>
In-Reply-To: <20080611180228.12987026@kernel>
References: <20080611180228.12987026@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linuxfoundation.org, hans.rosenfeld@amd.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 11:02:29 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> 
> We need this at least for huge page detection for now.
> 
> It might also come in handy for some of the other
> users.
> 

Changelog fails to explain why the `walk' argument was deconstified and
I couldn't immediately work this out from the diff.


> +	struct mm_walk smaps_walk = {
> +		.pmd_entry = smaps_pte_range,
> +		.mm = vma->vm_mm,
> +		.private = &mss,
> +	};

a)

>  	if (mm) {
> +		static struct mm_walk clear_refs_walk;
> +		memset(&clear_refs_walk, 0, sizeof(clear_refs_walk));
> +		clear_refs_walk.pmd_entry = clear_refs_pte_range;
> +		clear_refs_walk.mm = mm;

b)

where a) != b).  a) looks nicer.

Please do prefer to put a blank line between end-of-locals and
start-of-code.  It does improve readability.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
