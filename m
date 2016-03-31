Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f176.google.com (mail-yw0-f176.google.com [209.85.161.176])
	by kanga.kvack.org (Postfix) with ESMTP id C4FFE6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 12:44:24 -0400 (EDT)
Received: by mail-yw0-f176.google.com with SMTP id h65so104494407ywe.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 09:44:24 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id k189si2844530ywg.200.2016.03.31.09.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 09:44:24 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id f6so12269531ywa.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 09:44:23 -0700 (PDT)
Date: Thu, 31 Mar 2016 12:44:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] writeback: fix the wrong congested state variable
 definition
Message-ID: <20160331164422.GB24661@htj.duckdns.org>
References: <1459430381-13947-1-git-send-email-xiakaixu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459430381-13947-1-git-send-email-xiakaixu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kaixu Xia <xiakaixu@huawei.com>
Cc: axboe@kernel.dk, lizefan@huawei.com, jack@suse.cz, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, neilb@suse.de, linux-kernel@vger.kernel.org

On Thu, Mar 31, 2016 at 01:19:41PM +0000, Kaixu Xia wrote:
> The right variable definition should be wb_congested_state that
> include WB_async_congested and WB_sync_congested. So fix it.
> 
> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
