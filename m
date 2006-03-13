Date: Mon, 13 Mar 2006 15:52:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 1/8 migrate task memory
 with default policy
In-Reply-To: <1142019479.5204.15.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0603131547020.13713@schroedinger.engr.sgi.com>
References: <1142019479.5204.15.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Mar 2006, Lee Schermerhorn wrote:

> +/*
> + * Migrate all eligible pages mapped in vma NOT on destination node to
> + * the destination node.
> + * Returns error or the number of pages not migrated.
> + */
> +static int migrate_vma_to_node(struct vm_area_struct *vma, int dest, int flags)
> +{

This duplicates code in migrate_to_node().

> +/*
> + * for filtering 'no access' segments
> +TODO:  what are these?

??

> +	down_read(&mm->mmap_sem);
> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		struct mempolicy *pol = get_vma_policy(current, vma,
> +							 vma->vm_start);
> +		int err;
> +
> +		if (pol->policy != MPOL_DEFAULT)
> +			continue;
> +		if (vma_no_access(vma))
> +			continue;
> +
> +		// TODO:  more eligibility filtering?
> +
> +		// TODO:  more agressive migration ['MOVE_ALL] ?
> +		//        via sysctl?
> +		err = migrate_vma_to_node(vma, dest, MPOL_MF_MOVE);
> +
> +	}

Duplicates code in migrate_to_node().

Could you add some special casing instead to migrate_to_node and/or 
check_range?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
