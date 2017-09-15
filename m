Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2996B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 09:33:22 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 11so4775422pge.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 06:33:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g127si630684pgc.775.2017.09.15.06.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 06:33:21 -0700 (PDT)
Subject: Re: [f2fs-dev] [PATCH 05/15] f2fs: Use pagevec_lookup_range_tag()
References: <20170914131819.26266-1-jack@suse.cz>
 <20170914131819.26266-6-jack@suse.cz>
From: Chao Yu <chao@kernel.org>
Message-ID: <e98f9561-8d71-6011-d686-d9173f55dc2c@kernel.org>
Date: Fri, 15 Sep 2017 21:33:05 +0800
MIME-Version: 1.0
In-Reply-To: <20170914131819.26266-6-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-f2fs-devel@lists.sourceforge.net, "Yan, Zheng" <zyan@redhat.com>, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>

On 2017/9/14 21:18, Jan Kara wrote:
> We want only pages from given range in f2fs_write_cache_pages(). Use
> pagevec_lookup_range_tag() instead of pagevec_lookup_tag() and remove
> unnecessary code.
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
