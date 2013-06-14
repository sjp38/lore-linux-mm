Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A71636B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 04:25:57 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1371195041-26654-7-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371195041-26654-7-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: RE: [PATCH 7/8] mm/thp: fix doc for transparent huge zero page
Content-Transfer-Encoding: 7bit
Message-Id: <20130614082836.945E5E0090@blue.fi.intel.com>
Date: Fri, 14 Jun 2013 11:28:36 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Wanpeng Li wrote:
> Transparent huge zero page is used during the page fault instead of
> in khugepaged.
> 
> # ls /sys/kernel/mm/transparent_hugepage/
> defrag  enabled  khugepaged  use_zero_page
> # ls /sys/kernel/mm/transparent_hugepage/khugepaged/
> alloc_sleep_millisecs  defrag  full_scans  max_ptes_none  pages_collapsed  pages_to_scan  scan_sleep_millisecs
> 
> This patch corrects the documentation just like the codes done.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
