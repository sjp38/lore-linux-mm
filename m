Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 130B26B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 04:06:18 -0500 (EST)
Message-ID: <4F30E97F.9000409@ingenic.cn>
Date: Tue, 07 Feb 2012 17:06:07 +0800
From: "cp.zou" <cpzou@ingenic.cn>
MIME-Version: 1.0
Subject: Contiguous Memory Allocator on HIGHMEM
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

Hello everyone!

I'm recently learning CMA, and I want to implement support for
contiguous memory areas placed in HIGHMEM zone,do you have any suggestions?

-- 
Regards,
cary.zou

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
