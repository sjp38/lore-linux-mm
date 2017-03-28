Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 716FD6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 19:30:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 187so1658274wmn.5
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 16:30:59 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id q69si4964424wmd.149.2017.03.28.16.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 16:30:58 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id x124so2250858wmf.3
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 16:30:58 -0700 (PDT)
Date: Wed, 29 Mar 2017 02:30:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm -v7 1/9] mm, swap: Make swap cluster size same of THP
 size on x86_64
Message-ID: <20170328233056.zkp733h5kij7lfdb@node.shutemov.name>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-2-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328053209.25876-2-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Tue, Mar 28, 2017 at 01:32:01PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> In this patch, the size of the swap cluster is changed to that of the
> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
> the THP swap support on x86_64.  Where one swap cluster will be used to
> hold the contents of each THP swapped out.  And some information of the
> swapped out THP (such as compound map count) will be recorded in the
> swap_cluster_info data structure.
> 
> For other architectures which want THP swap support,
> ARCH_USES_THP_SWAP_CLUSTER need to be selected in the Kconfig file for
> the architecture.

Intreseting case could be architecture with HPAGE_PMD_NR < 256.
Can current code pack more than one THP per claster.

If not we need to have BUILG_BUG_ON() to catch attempt of such enabling.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
