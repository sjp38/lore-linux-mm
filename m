Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0213E6B025E
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:21:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so37429135wmu.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:21:56 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id i3si54597335wja.200.2016.11.28.06.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 06:21:55 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id a20so19290585wme.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:21:55 -0800 (PST)
Date: Mon, 28 Nov 2016 15:21:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 04/12] mm: thp: introduce
 CONFIG_ARCH_ENABLE_THP_MIGRATION
Message-ID: <20161128142154.GM14788@dhcp22.suse.cz>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 08-11-16 08:31:49, Naoya Horiguchi wrote:
> Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
> functionality to x86_64, which should be safer at the first step.

Please make sure to describe why this has to be arch specific and what
are arches supposed to provide in order to enable this option.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
