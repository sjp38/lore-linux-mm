Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C1A8C6B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 00:53:09 -0500 (EST)
Message-ID: <50E51C0B.1040205@redhat.com>
Date: Thu, 03 Jan 2013 00:50:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/9] mm: directly use __mlock_vma_pages_range() in find_extend_vma()
References: <1356050997-2688-1-git-send-email-walken@google.com> <1356050997-2688-9-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-9-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2012 07:49 PM, Michel Lespinasse wrote:
> In find_extend_vma(), we don't need mlock_vma_pages_range() to verify the
> vma type - we know we're working with a stack. So, we can call directly
> into __mlock_vma_pages_range(), and remove the last make_pages_present()
> call site.
>
> Note that we don't use mm_populate() here, so we can't release the mmap_sem
> while allocating new stack pages. This is deemed acceptable, because the
> stack vmas grow by a bounded number of pages at a time, and these are
> anon pages so we don't have to read from disk to populate them.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
