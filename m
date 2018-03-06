Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85A886B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 12:08:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v3so8358930pfm.21
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 09:08:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10-v6sor1896522pls.24.2018.03.06.09.08.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 09:08:34 -0800 (PST)
Subject: Re: [PATCH 6/7] lkdtm: crash on overwriting protected pmalloc var
From: J Freyensee <why2jjj.linux@gmail.com>
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-7-igor.stoppa@huawei.com>
 <1120e8fd-2f48-5b1f-7072-9bd8e2b82fbf@gmail.com>
Message-ID: <679444bd-7b41-4fb0-d7ba-98ed86da86c5@gmail.com>
Date: Tue, 6 Mar 2018 09:08:30 -0800
MIME-Version: 1.0
In-Reply-To: <1120e8fd-2f48-5b1f-7072-9bd8e2b82fbf@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 3/6/18 9:05 AM, J Freyensee wrote:
>
>> A  +#ifdef CONFIG_PROTECTABLE_MEMORY
>> +void lkdtm_WRITE_RO_PMALLOC(void)
>> +{
>> +A A A  struct gen_pool *pool;
>> +A A A  int *i;
>> +
>> +A A A  pool = pmalloc_create_pool("pool", 0);
>> +A A A  if (unlikely(!pool)) {
>> +A A A A A A A  pr_info("Failed preparing pool for pmalloc test.");
>> +A A A A A A A  return;
>> +A A A  }
>> +
>> +A A A  i = (int *)pmalloc(pool, sizeof(int), GFP_KERNEL);
>> +A A A  if (unlikely(!i)) {
>> +A A A A A A A  pr_info("Failed allocating memory for pmalloc test.");
>> +A A A A A A A  pmalloc_destroy_pool(pool);
>> +A A A A A A A  return;
>> +A A A  }
>> +
>> +A A A  *i = INT_MAX;
>> +A A A  pmalloc_protect_pool(pool);
>> +
>> +A A A  pr_info("attempting bad pmalloc write at %p\n", i);
>> +A A A  *i = 0;
>

Opps, disregard this, this is the last series of this patch series, not 
the most recent one :-(.



> Seems harmless, but I don't get why *i local variable needs to be set 
> to 0 at the end of this function.
>
>
> Otherwise,
>
> Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
