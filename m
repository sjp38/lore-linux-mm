Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f206.google.com (mail-ie0-f206.google.com [209.85.223.206])
	by kanga.kvack.org (Postfix) with ESMTP id D126F6B0031
	for <linux-mm@kvack.org>; Sun, 22 Dec 2013 11:18:48 -0500 (EST)
Received: by mail-ie0-f206.google.com with SMTP id lx4so64334iec.9
        for <linux-mm@kvack.org>; Sun, 22 Dec 2013 08:18:48 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id p46si13370752eem.189.2013.12.21.08.36.52
        for <linux-mm@kvack.org>;
        Sat, 21 Dec 2013 08:36:53 -0800 (PST)
Date: Sat, 21 Dec 2013 18:36:48 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fix build of split ptlock code
Message-ID: <20131221163648.GA25306@node.dhcp.inet.fi>
References: <1387578485-11829-1-git-send-email-olof@lixom.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1387578485-11829-1-git-send-email-olof@lixom.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Fri, Dec 20, 2013 at 02:28:05PM -0800, Olof Johansson wrote:
> Commit 597d795a2a78 ('mm: do not allocate page->ptl dynamically, if
> spinlock_t fits to long') restructures some allocators that are compiled
> even if USE_SPLIT_PTLOCKS arn't used. It results in compilation failure:
> 
> mm/memory.c:4282:6: error: 'struct page' has no member named 'ptl'
> mm/memory.c:4288:12: error: 'struct page' has no member named 'ptl'
> 
> Add in the missing ifdef.
> 
> Fixes: 597d795a2a78 ('mm: do not allocate page->ptl dynamically, if spinlock_t fits to long')
> Signed-off-by: Olof Johansson <olof@lixom.net>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>

Sorry, for that.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
