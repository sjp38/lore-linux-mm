Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 75A6F6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 05:33:22 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id z6so1191617yhz.2
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 02:33:21 -0800 (PST)
Message-ID: <512354C4.2040705@gmail.com>
Date: Tue, 19 Feb 2013 18:32:36 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: PAGE_CACHE_SIZE vs. PAGE_SIZE
References: <20130118155724.GA8507@otc-wbsnb-06>
In-Reply-To: <20130118155724.GA8507@otc-wbsnb-06>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On 01/18/2013 11:57 PM, Kirill A. Shutemov wrote:
> Hi,
>
> PAGE_CACHE_* macros were introduced long time ago in hope to implement
> page cache with larger chunks than one page in future.
>
> In fact it was never done.
>
> Some code paths assume PAGE_CACHE_SIZE <= PAGE_SIZE. E.g. we use
> zero_user_segments() to clear stale parts of page on cache filling, but
> the function is implemented only for individual small page.
>
> It's unlikely that global switch to PAGE_CACHE_SIZE > PAGE_SIZE will never
> happen since it will affect to much code at once.
>
> I think support of larger chunks in page cache can be in implemented in
> some form of THP with per-fs enabling.

IIRC, you try to implement THP support page cache, then PAGE_CACHE_SIZE 
maybe don't need any more.

>
> Is it time to get rid of PAGE_CACHE_* macros?
> I can prepare patchset if it's okay.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
