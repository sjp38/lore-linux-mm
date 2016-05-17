Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDCA86B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 01:14:46 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y84so2672711lfc.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 22:14:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si1916976wmb.12.2016.05.16.22.14.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 22:14:45 -0700 (PDT)
Subject: Re: Question About Functions "__free_pages_check" and
 "check_new_page" in page_alloc.c
References: <7374bd2e.da35.154b9cda7d2.Coremail.wang_xiaoq@126.com>
 <20160516151657.GC23251@dhcp22.suse.cz>
 <5877fe6c.1e45.154bc401c81.Coremail.wang_xiaoq@126.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573AA8C2.2060606@suse.cz>
Date: Tue, 17 May 2016 07:14:42 +0200
MIME-Version: 1.0
In-Reply-To: <5877fe6c.1e45.154bc401c81.Coremail.wang_xiaoq@126.com>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wang_xiaoq@126.com>, Michal Hocko <mhocko@kernel.org>, n-horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On 05/17/2016 03:06 AM, Wang Xiaoqiang wrote:
>>yes it would. Why that would matter. The checks should be in an order
>>which could give us a more specific reason with later checks. bad_page()
> 
> I see, you mean the later "bad_reason" is the superset of the previous one.

Not exactly. It's not possible to sort all the reasons like that. But as
Michal said, bad_page() will print all the relevant info so you can
reconstruct all reasons from it. The bad_reason text is mostly a hint
what to check first.

>>will then print more detailed information.
>>--
>>Michal Hocko
>>SUSE Labs
> 
> thank you, Michal.
> 
> 
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
