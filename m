Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9049A280290
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 06:18:44 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id o141so3922920lff.7
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 03:18:44 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id z132si5307839lff.45.2016.11.11.03.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 03:18:43 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id g23so8752916wme.1
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 03:18:43 -0800 (PST)
Date: Fri, 11 Nov 2016 14:18:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 04/12] mm: thp: introduce
 CONFIG_ARCH_ENABLE_THP_MIGRATION
Message-ID: <20161111111840.GF19382@node.shutemov.name>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Nov 08, 2016 at 08:31:49AM +0900, Naoya Horiguchi wrote:
> +static inline bool thp_migration_supported(void)
> +{
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +	return true;
> +#else
> +	return false;
> +#endif

Em..

	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);

?

Otherwise looks good to me.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
