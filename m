From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] zswap: get swapper address_space by using
 swap_address_space macro
Date: Fri, 12 Jul 2013 13:47:39 +0800
Message-ID: <41702.8929376558$1373608080@news.gmane.org>
References: <1373604175-19562-1-git-send-email-sunghan.suh@samsung.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UxWCt-00008u-Hy
	for glkm-linux-mm-2@m.gmane.org; Fri, 12 Jul 2013 07:47:51 +0200
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 632FA6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 01:47:48 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 12 Jul 2013 11:10:13 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 4A03CE0055
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 11:17:30 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6C5mI4W30015542
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 11:18:18 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6C5levK012153
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 15:47:40 +1000
Content-Disposition: inline
In-Reply-To: <1373604175-19562-1-git-send-email-sunghan.suh@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sunghan Suh <sunghan.suh@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org

On Fri, Jul 12, 2013 at 01:42:55PM +0900, Sunghan Suh wrote:
>Signed-off-by: Sunghan Suh <sunghan.suh@samsung.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/zswap.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/zswap.c b/mm/zswap.c
>index deda2b6..efed4c8 100644
>--- a/mm/zswap.c
>+++ b/mm/zswap.c
>@@ -409,7 +409,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
> 				struct page **retpage)
> {
> 	struct page *found_page, *new_page = NULL;
>-	struct address_space *swapper_space = &swapper_spaces[swp_type(entry)];
>+	struct address_space *swapper_space = swap_address_space(entry);
> 	int err;
>
> 	*retpage = NULL;
>-- 
>1.8.1.2
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
