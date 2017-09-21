Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 90E956B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 07:52:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r74so5597073wme.5
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 04:52:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d90si1370443edd.470.2017.09.21.04.52.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Sep 2017 04:52:13 -0700 (PDT)
Date: Thu, 21 Sep 2017 13:52:06 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4] mm: introduce validity check on vm dirtiness settings
Message-ID: <20170921115206.GB16731@quack2.suse.cz>
References: <1506002392-11907-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506002392-11907-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: jack@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mcgrof@kernel.org, keescook@chromium.org, wuqixuan@huawei.com

On Thu 21-09-17 21:59:52, Yafang Shao wrote:
> we can find the logic in domain_dirty_limits() that
> when dirty bg_thresh is bigger than dirty thresh,
> bg_thresh will be set as thresh * 1 / 2.
> 	if (bg_thresh >= thresh)
> 		bg_thresh = thresh / 2;
> 
> But actually we can set vm background dirtiness bigger than
> vm dirtiness successfully. This behavior may mislead us.
> We'd better do this validity check at the beginning.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

Just one nit below:

> +
> +    /* needn't do validity check if the value is not different. */
> +	if (ret == 0 && write && dirty_background_ratio != old_ratio) {

Whitespace before the comment is broken. Generally I don't think the
comment brings much so I'd just delete it.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
