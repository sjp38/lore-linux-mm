Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0D26B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 09:38:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j16so4780231pga.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 06:38:16 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 94si720718pla.781.2017.09.15.06.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 06:38:14 -0700 (PDT)
Subject: Re: [f2fs-dev] [PATCH 06/15] f2fs: Simplify page iteration loops
References: <20170914131819.26266-1-jack@suse.cz>
 <20170914131819.26266-7-jack@suse.cz>
From: Chao Yu <chao@kernel.org>
Message-ID: <3c0acdd7-c8ae-9548-c354-0275fa3f8176@kernel.org>
Date: Fri, 15 Sep 2017 21:37:59 +0800
MIME-Version: 1.0
In-Reply-To: <20170914131819.26266-7-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-f2fs-devel@lists.sourceforge.net, "Yan, Zheng" <zyan@redhat.com>, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>

On 2017/9/14 21:18, Jan Kara wrote:
> In several places we want to iterate over all tagged pages in a mapping.
> However the code was apparently copied from places that iterate only
> over a limited range and thus it checks for index <= end, optimizes the
> case where we are coming close to range end which is all pointless when
> end == ULONG_MAX. So just remove this dead code.
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
