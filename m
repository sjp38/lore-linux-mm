Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EA84882F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 17:39:01 -0500 (EST)
Received: by pasz6 with SMTP id z6so139622669pas.2
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 14:39:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gg7si3005043pbc.147.2015.11.06.14.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 14:39:01 -0800 (PST)
Date: Fri, 6 Nov 2015 14:39:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-Id: <20151106143900.e61c38b5bf3e44547873d9d2@linux-foundation.org>
In-Reply-To: <20151106102921.GA6463@node.shutemov.name>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
	<20151105163211.608eec970de21a95faf6e156@linux-foundation.org>
	<20151106102921.GA6463@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>

On Fri, 6 Nov 2015 12:29:21 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > page_mapcount() is getting pretty bad too.
> 
> Do you want me to uninline slow path (PageCompound())?

I guess so.  Uninlining all of page_mapcount() does this:

gcc-4.4.4:

   text    data     bss     dec     hex filename
 973702  273954  831512 2079168  1fb9c0 mm/built-in.o-before
 970148  273954  831000 2075102  1fa9de mm/built-in.o-after

That's quite a bit of bloat.

I don't know why bss changed; this usually (always?) happens.  Seems
bogus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
