Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 803E16B025E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:30:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so28175428wmz.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:30:18 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id q63si3773878wmd.131.2016.08.09.09.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 09:30:14 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id q128so4226424wma.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:30:14 -0700 (PDT)
Date: Tue, 9 Aug 2016 19:30:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp: move shmem_huge_enabled() outside of SYSFS ifdef
Message-ID: <20160809163011.GB10293@node.shutemov.name>
References: <20160809123638.1357593-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160809123638.1357593-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 09, 2016 at 02:36:02PM +0200, Arnd Bergmann wrote:
> The newly introduced shmem_huge_enabled() function has two definitions,
> but neither of them is visible if CONFIG_SYSFS is disabled, leading
> to a build error:
> 
> mm/khugepaged.o: In function `khugepaged':
> khugepaged.c:(.text.khugepaged+0x3ca): undefined reference to `shmem_huge_enabled'
> 
> This changes the #ifdef guards around the definition to match those that
> are used in the header file.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: e496cf3d7821 ("thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE")

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
