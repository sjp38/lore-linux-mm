Date: Fri, 20 Oct 2006 23:10:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/2] shared page table for hugetlb page - v4
In-Reply-To: <000001c6f3b2$0c70b8c0$ff0da8c0@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0610202253190.963@blonde.wat.veritas.com>
References: <000001c6f3b2$0c70b8c0$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, Hugh Blemings <hab@au1.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006, Chen, Kenneth W wrote:
> Re-diff against git tree as of this morning since some of the changes
> were committed for a different reason. No other change from last version.
> I was hoping Hugh finds time to review version v4 posted about two weeks
> ago.  Though I don't want to wait for too long to rebase. So here we go:

They both look fine to me now, Ken.

(I was expecting a problem with your vma_prio_tree_fornext idx, but
testing showed I was wrong about that: as I guess you already found,
it's the h_pgoff in hugetlb_vmtruncate_list's vma_prio_tree_fornext
which is wrong, but wrong in a safe way so we've never noticed:
I'll test and send in a patch for that tomorrow.)

You can add my
Acked-by: Hugh Dickins <hugh@veritas.com>
to both patches, but it's no longer worth much: I notice Andrew has
grown so disillusioned by my sluggardly responses that he's rightly
decided to CC Hugh Blemings instead ;)  Over to you, Hugh!

HughD

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
