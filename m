Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A624F280290
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 06:16:56 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id o20so3961255lfg.2
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 03:16:56 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id g4si5293513ljg.73.2016.11.11.03.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 03:16:55 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m203so7056344wma.3
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 03:16:55 -0800 (PST)
Date: Fri, 11 Nov 2016 14:16:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 03/12] mm: thp: introduce separate TTU flag for thp
 freezing
Message-ID: <20161111111652.GE19382@node.shutemov.name>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478561517-4317-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Nov 08, 2016 at 08:31:48AM +0900, Naoya Horiguchi wrote:
> TTU_MIGRATION is used to convert pte into migration entry until thp split
> completes. This behavior conflicts with thp migration added later patches,
> so let's introduce a new TTU flag specifically for freezing.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
