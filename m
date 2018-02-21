Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6EB6B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 06:18:54 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id h82so419653lfe.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 03:18:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u64sor3280825lja.58.2018.02.21.03.18.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 03:18:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180221102237.GB14384@dhcp22.suse.cz>
References: <20180220175811.GA28277@jordon-HP-15-Notebook-PC> <20180221102237.GB14384@dhcp22.suse.cz>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 21 Feb 2018 16:48:50 +0530
Message-ID: <CAFqt6za=iGsXKa=2dfjOq=7fKy+BxAq_=08=OYPmAy8GwugXAA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: zsmalloc: Replace return type int with bool
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com, Linux-MM <linux-mm@kvack.org>

On Wed, Feb 21, 2018 at 3:52 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 20-02-18 23:28:11, Souptick Joarder wrote:
> [...]
>> -static int zs_register_migration(struct zs_pool *pool)
>> +static bool zs_register_migration(struct zs_pool *pool)
>>  {
>>       pool->inode = alloc_anon_inode(zsmalloc_mnt->mnt_sb);
>>       if (IS_ERR(pool->inode)) {
>>               pool->inode = NULL;
>> -             return 1;
>> +             return true;
>>       }
>>
>>       pool->inode->i_mapping->private_data = pool;
>>       pool->inode->i_mapping->a_ops = &zsmalloc_aops;
>> -     return 0;
>> +     return false;
>>  }
>
> Don't you find it a bit strange that the function returns false on
> success?

The original code was returning 0 on success  and return value was handled
accordingly in zs_create_pool(). So returning false on success.

Shall I change it ?
> --
> Michal Hocko
> SUSE Labs

-Souptick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
