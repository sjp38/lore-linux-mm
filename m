Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 4AD656B0032
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 20:15:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 10:03:46 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 69CBB3578050
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 10:15:06 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r830Etnd9109788
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 10:14:55 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r830F5aj021196
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 10:15:05 +1000
Date: Tue, 3 Sep 2013 08:15:04 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: fix accounting on page_remove_rmap()
Message-ID: <20130903001504.GA21530@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1378122191-15479-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378122191-15479-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ning Qu <quning@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 02, 2013 at 02:43:11PM +0300, Kirill A. Shutemov wrote:
>There's typo in page_remove_rmap(): we increase NR_ANON_PAGES counter
>instead of decreasing it. Let's fix this.
>
>Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>Reported-by: Ning Qu <quning@google.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/rmap.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/rmap.c b/mm/rmap.c
>index 52cc59a..6219f07 100644
>--- a/mm/rmap.c
>+++ b/mm/rmap.c
>@@ -1156,7 +1156,7 @@ void page_remove_rmap(struct page *page)
> 			__dec_zone_page_state(page,
> 					      NR_ANON_TRANSPARENT_HUGEPAGES);
> 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
>-				hpage_nr_pages(page));
>+				-hpage_nr_pages(page));
> 	} else {
> 		__dec_zone_page_state(page, NR_FILE_MAPPED);
> 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
>-- 
>1.8.4.rc3
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
