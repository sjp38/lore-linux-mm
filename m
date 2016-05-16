Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7145E6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 11:17:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so101760837lfc.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 08:17:00 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id kl3si38423114wjb.22.2016.05.16.08.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 08:16:59 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so18749439wmw.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 08:16:59 -0700 (PDT)
Date: Mon, 16 May 2016 17:16:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Question About Functions "__free_pages_check" and
 "check_new_page" in page_alloc.c
Message-ID: <20160516151657.GC23251@dhcp22.suse.cz>
References: <7374bd2e.da35.154b9cda7d2.Coremail.wang_xiaoq@126.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7374bd2e.da35.154b9cda7d2.Coremail.wang_xiaoq@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wang_xiaoq@126.com>
Cc: vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 16-05-16 21:42:23, Wang Xiaoqiang wrote:
> Hi all,
> 
>     I am really confused about these two functions. The following code snippet:
> 
> if(unlikely(atomic_read(&page->_mapcount) != -1))
> 		bad_reason ="nonzero mapcount";if(unlikely(page->mapping != NULL))
> 		bad_reason ="non-NULL mapping";if(unlikely(page_ref_count(page) !=0))
> 		bad_reason ="nonzero _count";
>         ...
> Wouldn't the previous value of "bad_reason" be overwritten by 
> the later? Hope to receive from you.

yes it would. Why that would matter. The checks should be in an order
which could give us a more specific reason with later checks. bad_page()
will then print more detailed information.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
