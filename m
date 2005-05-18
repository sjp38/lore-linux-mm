Date: Wed, 18 May 2005 09:37:04 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
Message-ID: <20050518073703.GA5432@elte.hu>
References: <E4BA51C8E4E9634993418831223F0A49291F06E1@scsmsx401.amr.corp.intel.com> <200505172228.j4HMSkg28528@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200505172228.j4HMSkg28528@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Wolfgang Wander' <wwc@rentec.com>, 'Andrew Morton' <akpm@osdl.org>, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:

> Please note, this patch completely obsoletes previous patch that 
> Wolfgang posted and should completely retain the performance benefit 
> of free_area_cache and at the same time preserving fragmentation to 
> minimum.
> 
> Andrew, please consider for -mm testing.  Thanks.

very nice patch!

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
