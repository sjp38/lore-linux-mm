Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 903BA6B0005
	for <linux-mm@kvack.org>; Sun,  6 Mar 2016 19:58:14 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 124so70007116pfg.0
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 16:58:14 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id cl8si24730106pad.110.2016.03.06.16.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Mar 2016 16:58:13 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id 184so7023304pff.1
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 16:58:13 -0800 (PST)
Date: Mon, 7 Mar 2016 11:58:04 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v1 02/11] mm: thp: introduce
 CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
Message-ID: <20160307005804.GA25148@cotter.ozlabs.ibm.com>
Reply-To: bsingharora@gmail.com
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1456990918-30906-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456990918-30906-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Mar 03, 2016 at 04:41:49PM +0900, Naoya Horiguchi wrote:
> Introduces CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION to limit thp migration
> functionality to x86_64, which should be safer at the first step.
>

The changelog is not helpful. Could you please describe what is
architecture specific in these changes? What do other arches need to do
to port these changes over?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
