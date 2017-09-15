Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F57D6B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 09:43:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so4827597pgn.2
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 06:43:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a9si667318pgd.273.2017.09.15.06.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 06:43:19 -0700 (PDT)
Subject: Re: [f2fs-dev] [PATCH 07/15] f2fs: Use find_get_pages_tag() for
 looking up single page
References: <20170914131819.26266-1-jack@suse.cz>
 <20170914131819.26266-8-jack@suse.cz>
From: Chao Yu <chao@kernel.org>
Message-ID: <2cd84505-3d52-61dc-4a8d-099a58467cc1@kernel.org>
Date: Fri, 15 Sep 2017 21:43:03 +0800
MIME-Version: 1.0
In-Reply-To: <20170914131819.26266-8-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-f2fs-devel@lists.sourceforge.net, "Yan, Zheng" <zyan@redhat.com>, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>

On 2017/9/14 21:18, Jan Kara wrote:
> __get_first_dirty_index() wants to lookup only the first dirty page
> after given index. There's no point in using pagevec_lookup_tag() for
> that. Just use find_get_pages_tag() directly.
> 
> CC: Jaegeuk Kim <jaegeuk@kernel.org>
> CC: linux-f2fs-devel@lists.sourceforge.net
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Chao Yu <yuchao0@huawei.com>

Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
