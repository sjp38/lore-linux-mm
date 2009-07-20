Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C54626B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 10:48:56 -0400 (EDT)
Message-ID: <4A6483D4.60302@redhat.com>
Date: Mon, 20 Jul 2009 10:48:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] ksm: add mmu_notifier set_pte_at_notify()
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-2-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> From: Izik Eidus <ieidus@redhat.com>
> 
> The set_pte_at_notify() macro allows setting a pte in the shadow page
> table directly, instead of flushing the shadow page table entry and then
> getting vmexit to set it.  It uses a new change_pte() callback to do so.
> 
> set_pte_at_notify() is an optimization for kvm, and other users of
> mmu_notifiers, for COW pages.  It is useful for kvm when ksm is used,
> because it allows kvm not to have to receive vmexit and only then map
> the ksm page into the shadow page table, but instead map it directly
> at the same time as Linux maps the page into the host page table.
> 
> Users of mmu_notifiers who don't implement new mmu_notifier_change_pte()
> callback will just receive the mmu_notifier_invalidate_page() callback.
> 
> Signed-off-by: Izik Eidus <ieidus@redhat.com>
> Signed-off-by: Chris Wright <chrisw@redhat.com>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
