Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 075438D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 12:59:15 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH]mmap: avoid unnecessary anon_vma lock
References: <1301277532.3981.25.camel@sli10-conroe>
Date: Mon, 28 Mar 2011 09:57:39 -0700
In-Reply-To: <1301277532.3981.25.camel@sli10-conroe> (Shaohua Li's message of
	"Mon, 28 Mar 2011 09:58:52 +0800")
Message-ID: <m2fwq718u4.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Shaohua Li <shaohua.li@intel.com> writes:

> If we only change vma->vm_end, we can avoid taking anon_vma lock even 'insert'
> isn't NULL, which is the case of split_vma.
> From my understanding, we need the lock before because rmap must get the
> 'insert' VMA when we adjust old VMA's vm_end (the 'insert' VMA is linked to
> anon_vma list in __insert_vm_struct before).
> But now this isn't true any more. The 'insert' VMA is already linked to
> anon_vma list in __split_vma(with anon_vma_clone()) instead of
> __insert_vm_struct. There is no race rmap can't get required VMAs.
> So the anon_vma lock is unnecessary, and this can reduce one locking in brk
> case and improve scalability.

Looks good to me.
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
