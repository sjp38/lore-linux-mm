Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 613456B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 07:25:30 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <52283AF9.2080606@huawei.com>
References: <52283AF9.2080606@huawei.com>
Subject: RE: [PATCH v2][RESEND] mm/thp: fix stale comments of
 transparent_hugepage_flags
Content-Transfer-Encoding: 7bit
Message-Id: <20130905112524.CD222E0090@blue.fi.intel.com>
Date: Thu,  5 Sep 2013 14:25:24 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, Mel Gorman <mgorman@suse.de>, xiaoguangrong@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Jianguo Wu wrote:
> Changelog:
>  *v1 -> v2: also update the stale comments about default transparent
> hugepage support pointed by Wanpeng Li.
> 
> Since commit 13ece886d9(thp: transparent hugepage config choice),
> transparent hugepage support is disabled by default, and
> TRANSPARENT_HUGEPAGE_ALWAYS is configured when TRANSPARENT_HUGEPAGE=y.
> 
> And since commit d39d33c332(thp: enable direct defrag), defrag is
> enable for all transparent hugepage page faults by default, not only in
> MADV_HUGEPAGE regions.
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
