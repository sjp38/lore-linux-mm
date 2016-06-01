Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0618B6B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 05:40:02 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ne4so6772932lbc.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:40:01 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id f87si15773968lji.20.2016.06.01.02.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 02:40:00 -0700 (PDT)
Received: by mail-lf0-x232.google.com with SMTP id s64so8933434lfe.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:40:00 -0700 (PDT)
Date: Wed, 1 Jun 2016 12:39:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1] mm: thp: check pmd_trans_unstable() after
 split_huge_pmd()
Message-ID: <20160601093957.GA8493@node.shutemov.name>
References: <1464741400-12143-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464741400-12143-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jun 01, 2016 at 09:36:40AM +0900, Naoya Horiguchi wrote:
> split_huge_pmd() doesn't guarantee that the pmd is normal pmd pointing to
> pte entries, which can be checked with pmd_trans_unstable().

Could you be more specific on when we don't have normal ptes after
split_huge_pmd? Race with other thread? DAX?

I guess we can modify split_huge_pmd() to return if the pmd was split or
not.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
