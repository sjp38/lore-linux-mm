Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 123146B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 09:24:50 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l66so73731370wml.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 06:24:50 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z77si15241524wmz.103.2016.02.01.06.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 06:24:48 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id l66so9367968wml.2
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 06:24:48 -0800 (PST)
Date: Mon, 1 Feb 2016 15:24:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: fix bogus VM_BUG_ON_PAGE() in isolate_lru_page()
Message-ID: <20160201142446.GB24008@dhcp22.suse.cz>
References: <1454333169-121369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454333169-121369-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454333169-121369-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 01-02-16 16:26:08, Kirill A. Shutemov wrote:
> We don't care if there's a tail pages which is not on LRU. We are not
> going to isolate them anyway.

yes we are not going to isolate them but calling this function on a
tail page is wrong in principle, no? PageLRU check is racy outside of
lru_lock so what if we are racing here. I know, highly unlikely but not
impossible. So I am not really sure this is an improvement. When would
we hit this VM_BUG_ON and it wouldn't be a bug or at least suspicious
usage?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
