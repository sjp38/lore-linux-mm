Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 086126B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 12:26:26 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so97236058wic.1
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 09:26:25 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id cw7si5092596wib.13.2015.09.19.09.26.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 09:26:24 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so66612303wic.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 09:26:24 -0700 (PDT)
Date: Sat, 19 Sep 2015 18:26:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm] mm/khugepaged: fix scan not aborted on
 SCAN_EXCEED_SWAP_PTE
Message-ID: <20150919162622.GC10158@dhcp22.suse.cz>
References: <1442591003-4880-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442591003-4880-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 18-09-15 18:43:23, Vladimir Davydov wrote:
[...]
> Fixes: acc067d59a1f9 ("mm: make optimistic check for swapin readahead")

This sha will not exist after the patch gets merged to the Linus tree
from the Andrew tree. Either reference it just by the subject or simply
mark it for Andrew to be folded into
mm-make-optimistic-check-for-swapin-readahead.patch
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
