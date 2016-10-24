Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B54D6B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 19:48:46 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xx10so4978826pac.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 16:48:46 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a5si17857795pgk.137.2016.10.24.16.48.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 16:48:45 -0700 (PDT)
Date: Tue, 25 Oct 2016 02:48:41 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2] shmem: avoid maybe-uninitialized warning
Message-ID: <20161024234841.dk673yxv7fhw5rx3@black.fi.intel.com>
References: <20161024205725.786455-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161024205725.786455-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andreas Gruenbacher <agruenba@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 24, 2016 at 10:57:09PM +0200, Arnd Bergmann wrote:
> After enabling -Wmaybe-uninitialized warnings, we get a false-postive
> warning for shmem:
> 
> mm/shmem.c: In function a??shmem_getpage_gfpa??:
> include/linux/spinlock.h:332:21: error: a??infoa?? may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This can be easily avoided, since the correct 'info' pointer is known
> at the time we first enter the function, so we can simply move the
> initialization up. Moving it before the first label avoids the
> warning and lets us remove two later initializations.
> 
> Note that the function is so hard to read that it not only confuses
> the compiler, but also most readers and without this patch it could\
> easily break if one of the 'goto's changed.
> 
> Link: https://www.spinics.net/lists/kernel/msg2368133.html
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
