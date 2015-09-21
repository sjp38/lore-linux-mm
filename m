Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC9A6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:53:58 -0400 (EDT)
Received: by padbj2 with SMTP id bj2so310732pad.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:53:58 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id is9si35867188pbc.208.2015.09.21.00.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 00:53:57 -0700 (PDT)
Date: Mon, 21 Sep 2015 10:53:46 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] mm/khugepaged: fix scan not aborted on
 SCAN_EXCEED_SWAP_PTE
Message-ID: <20150921075346.GA4995@esperanza>
References: <1442591003-4880-1-git-send-email-vdavydov@parallels.com>
 <20150919162622.GC10158@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150919162622.GC10158@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Sep 19, 2015 at 06:26:23PM +0200, Michal Hocko wrote:
> On Fri 18-09-15 18:43:23, Vladimir Davydov wrote:
> [...]
> > Fixes: acc067d59a1f9 ("mm: make optimistic check for swapin readahead")
> 
> This sha will not exist after the patch gets merged to the Linus tree
> from the Andrew tree. Either reference it just by the subject or simply
> mark it for Andrew to be folded into
> mm-make-optimistic-check-for-swapin-readahead.patch

AFAICS Andrew has already folded the fix into this patch:

  mm-make-optimistic-check-for-swapin-readahead-fix-2.patch

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
