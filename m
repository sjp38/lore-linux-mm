Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E11886B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 18:29:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d123so124175125pfd.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 15:29:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1si2120548plw.105.2017.02.06.15.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 15:29:34 -0800 (PST)
Date: Mon, 6 Feb 2017 15:29:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-Id: <20170206152932.19e7947df487b96b8912e524@linux-foundation.org>
In-Reply-To: <20170206154314.15705-1-richard.weiyang@gmail.com>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon,  6 Feb 2017 23:43:14 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> The whole memory space is divided into several zones and nodes may have no
> page in some zones. In this case, the __absent_pages_in_range() would
> return 0, since the range it is searching for is an empty range.
> 
> Also this happens more often to those nodes with higher memory range when
> there are more nodes, which is a trend for future architectures.
> 
> This patch checks the zone range after clamp and adjustment, return 0 if
> the range is an empty range.

What are the user-visible runtime effects of this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
