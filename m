Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BFDC6B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 04:36:18 -0400 (EDT)
Message-Id: <8u3s8d$jmp9g4@orsmga001.jf.intel.com>
Date: Mon, 27 Sep 2010 09:36:09 +0100
Subject: Re: How best to pin pages in physical memory?
References: <8u3s8d$jmkug0@orsmga001.jf.intel.com> <alpine.LSU.2.00.1009261559540.11745@sister.anvils>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <alpine.LSU.2.00.1009261559540.11745@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sun, 26 Sep 2010 16:29:23 -0700 (PDT), Hugh Dickins <hughd@google.com> wrote:
> If i915_get_object_get_pages() isn't doing its job, I think you need to
> wonder why not - maybe somewhere doing a put_page or page_cache_release,
> freeing one or all pages too soon?

Thanks, that's a very useful bit of review. I surmised that after seeing
corruption in a batch buffer after a swap storm that the pages were not as
safe required. The fact that swapping was involved could have been a
coincidence, except for the growing number of reports from other users
reporting crashes in conjunction with swapping.

So back to seeing whether i915_gem_object_[get/put]_pages is sufficient
for our uses.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
