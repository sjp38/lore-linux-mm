Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id EA56A6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:42:21 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id r129so51007579wmr.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:42:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si31121515wjq.3.2016.03.21.06.42.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 06:42:20 -0700 (PDT)
Date: Mon, 21 Mar 2016 14:41:51 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 22/71] btrfs: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160321134151.GI21722@suse.cz>
Reply-To: dsterba@suse.cz
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-23-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458499278-1516-23-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Mar 20, 2016 at 09:40:29PM +0300, Kirill A. Shutemov wrote:
> PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
> with promise that one day it will be possible to implement page cache with
> bigger chunks than PAGE_SIZE.
> 
> This promise never materialized. And unlikely will.
> 
> We have many places where PAGE_CACHE_SIZE assumed to be equal to
> PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
> or PAGE_* constant should be used in a particular case, especially on the
> border between fs and mm.
> 
> Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
> breakage to be doable.
> 
> Let's stop pretending that pages in page cache are special. They are not.
> 
> The changes are pretty straight-forward:
> 
>  - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;
> 
>  - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};
> 
>  - page_cache_get() -> get_page();
> 
>  - page_cache_release() -> put_page();
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Chris Mason <clm@fb.com>
> Cc: Josef Bacik <jbacik@fb.com>
> Cc: David Sterba <dsterba@suse.com>

Acked-by: David Sterba <dsterba@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
