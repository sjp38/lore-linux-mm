Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 097A96B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:55:51 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id j90so84157529lfi.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 02:55:50 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q11si4226671lfh.105.2017.01.25.02.55.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 02:55:49 -0800 (PST)
Subject: Re: [PATCH] mm/migration: make isolate_movable_page always defined
References: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <6ac6ec39-08d4-e8eb-4528-72e14a8cc0e7@huawei.com>
Date: Wed, 25 Jan 2017 18:50:03 +0800
MIME-Version: 1.0
In-Reply-To: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

Hi Andrew, Minchan, and all:
My former patch "HWPOISON: soft offlining for non-lru
movable page" will cause compiled error when disable
CONFIG_MIGRATION. And this is a patch to fixe it by
define isolate_movable_page as a static inline
function with !CONFIG_MIGRATION.

Could you please help to review it ? Thanks so much~

I am so sorry about that.

Thanks.
Yisheng Xie

On 2017/1/25 18:36, Yisheng Xie wrote:
> Define isolate_movable_page as a static inline function when
> CONFIG_MIGRATION is not enable. It should return false
> here which means failed to isolate movable pages.
> 
> This patch do not have any functional change but to resolve compile
> error caused by former commit "HWPOISON: soft offlining for non-lru
> movable page" with CONFIG_MIGRATION disabled.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  include/linux/migrate.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index ae8d475..631a8c8 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -56,6 +56,8 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
>  		free_page_t free, unsigned long private, enum migrate_mode mode,
>  		int reason)
>  	{ return -ENOSYS; }
> +static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> +	{ return false; }
>  
>  static inline int migrate_prep(void) { return -ENOSYS; }
>  static inline int migrate_prep_local(void) { return -ENOSYS; }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
