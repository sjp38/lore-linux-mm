Date: Sun, 12 Nov 2006 21:29:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [hugepage] Fix unmap_and_free_vma backout path
In-Reply-To: <20061113051318.GD27042@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0611122127080.2233@schroedinger.engr.sgi.com>
References: <20061113051318.GD27042@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Nov 2006, 'David Gibson' wrote:

> This may not be all we want.  Even with this patch, performing such a
> failing map on to of an existing mapping will clobber (unmap) that
> pre-existing mapping.  This is in contrast to the analogous situation
> with normal page mappings - mapping on top with a misaligned offset
> will fail early enough not to clobber the pre-existing mapping.

Then it is best to check the huge page alignment at the 
same place as regular alignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
