Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 0F8586B000E
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 17:40:27 -0500 (EST)
Date: Thu, 31 Jan 2013 14:40:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: PAGE_CACHE_SIZE vs. PAGE_SIZE
Message-Id: <20130131144026.bd735c07.akpm@linux-foundation.org>
In-Reply-To: <20130118155724.GA8507@otc-wbsnb-06>
References: <20130118155724.GA8507@otc-wbsnb-06>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, 18 Jan 2013 17:57:25 +0200
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

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
> 
> Is it time to get rid of PAGE_CACHE_* macros?
> I can prepare patchset if it's okay.

The distinct PAGE_CACHE_SIZE has never been used for anything, but I do
kinda like it for documentary reasons: PAGE_SIZE is a raw, low-level
thing and PAGE_CACHE_SIZE is the specialized
we're-doing-pagecache-stuff thing.

But I'm sure I could get used to not having it ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
