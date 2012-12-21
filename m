Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C12B36B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 03:55:08 -0500 (EST)
Date: Fri, 21 Dec 2012 09:55:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2012-12-20-16-15 uploaded
Message-ID: <20121221085506.GA13375@dhcp22.suse.cz>
References: <20121221001631.74ECA82004A@wpzn4.hot.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121221001631.74ECA82004A@wpzn4.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

cma-use-unsigned-type-for-count-argument-fix.patch has a typo:
@@ -1060,38 +1059,39 @@ static struct page **__iommu_alloc_buffe
 
 		__dma_clear_buffer(page, size);
 
-		for (i = 0; i < count; i++)
-			pages[i] = page + i;
+		for (idx = 0; idx < count; idx++)
+			pages[i] = page + idx;
 
 		return pages;
 	}
 
 	while (count) {
-		int j, order = __fls(count);
+		unsigned int j;
+		unnsigned int order = __fls(count);

s/unnsigned/unsigned/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
