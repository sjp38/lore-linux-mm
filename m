Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBFF06B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:31:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so96094842lfd.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:31:48 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id iz5si37583404wjb.86.2016.05.16.02.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 02:31:47 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id a17so126263536wme.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:31:47 -0700 (PDT)
Date: Mon, 16 May 2016 11:31:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: why the count nr_file_pages is not equal to nr_inactive_file +
 nr_active_file ?
Message-ID: <20160516093146.GA23251@dhcp22.suse.cz>
References: <573550D8.9030507@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573550D8.9030507@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 11:58:16, Xishi Qiu wrote:
> I find the count nr_file_pages is not equal to nr_inactive_file + nr_active_file.
> There are 8 cpus, 2 zones in my system.

Because they count shmem pages as well and those are living on the anon
lru list (see shmem_add_to_page_cache).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
