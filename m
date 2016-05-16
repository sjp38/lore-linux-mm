Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2E086B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:57:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so96370373lfd.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:57:22 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id n190si19116851wmg.90.2016.05.16.02.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 02:57:21 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id n129so94441282wmn.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:57:21 -0700 (PDT)
Date: Mon, 16 May 2016 11:57:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: why the count nr_file_pages is not equal to nr_inactive_file +
 nr_active_file ?
Message-ID: <20160516095720.GB23251@dhcp22.suse.cz>
References: <573550D8.9030507@huawei.com>
 <dce01643-7aa9-e779-e4ac-b74439f5074d@intel.com>
 <573582DE.3030302@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573582DE.3030302@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Aaron Lu <aaron.lu@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

[Sorry I haven't noticed this answer before]

On Fri 13-05-16 15:31:42, Xishi Qiu wrote:
> On 2016/5/13 15:00, Aaron Lu wrote:
> 
> Hi Aaron,
> 
> Thanks for your reply, but I find the count of nr_shmem is very small
> in my system.

which kernel version is this? I remember that we used to account thp
pages as NR_FILE_PAGE as well in the past.

I didn't get to look at your number more closely though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
