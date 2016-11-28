Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAAA6B0266
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:33:35 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o2so13783660wje.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:33:35 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id an4si54698257wjc.19.2016.11.28.06.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 06:33:34 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g23so19353479wme.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:33:34 -0800 (PST)
Date: Mon, 28 Nov 2016 15:33:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 06/12] mm: thp: enable thp migration in generic path
Message-ID: <20161128143331.GO14788@dhcp22.suse.cz>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-7-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478561517-4317-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 08-11-16 08:31:51, Naoya Horiguchi wrote:
> This patch makes it possible to support thp migration gradually. If you fail
> to allocate a destination page as a thp, you just split the source thp as we
> do now, and then enter the normal page migration. If you succeed to allocate
> destination thp, you enter thp migration. Subsequent patches actually enable
> thp migration for each caller of page migration by allowing its get_new_page()
> callback to allocate thps.

Does this need to be in a separate patch? Wouldn't it make more sense to
have the full THP migration code in a single one?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
