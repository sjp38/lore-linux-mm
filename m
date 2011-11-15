Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A9E276B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:17:31 -0500 (EST)
Date: Tue, 15 Nov 2011 19:17:28 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch v2 3/4]thp: add tlb_remove_pmd_tlb_entry
Message-ID: <20111115181728.GJ4414@redhat.com>
References: <1321340658.22361.296.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321340658.22361.296.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Tue, Nov 15, 2011 at 03:04:18PM +0800, Shaohua Li wrote:
> We have tlb_remove_tlb_entry to indicate a pte tlb flush entry should be
> flushed, but not a corresponding API for pmd entry. This isn't a problem so far
> because THP is only for x86 currently and tlb_flush() under x86 will flush
> entire TLB. But this is confusion and could be missed if thp is ported to
> other arch.
> Also converted tlb->need_flush = 1 to a VM_BUG_ON(!tlb->need_flush) in
> __tlb_remove_page() as suggested by Andrea Arcangeli. __tlb_remove_page()
> is supposed to be called after tlb_remove_xxx_tlb_entry() and we can catch
> any misuse.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
