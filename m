Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA756B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 22:39:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w207so162585390oiw.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 19:39:14 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id k27si21645332ioo.50.2016.07.29.19.39.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jul 2016 19:39:13 -0700 (PDT)
Message-ID: <579C132C.5050407@huawei.com>
Date: Sat, 30 Jul 2016 10:38:36 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fs: wipe off the compiler warn
References: <1469803600-44293-1-git-send-email-zhongjiang@huawei.com> <20160729160247.564e27525f04416ef714ddd4@linux-foundation.org>
In-Reply-To: <20160729160247.564e27525f04416ef714ddd4@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/7/30 7:02, Andrew Morton wrote:
> On Fri, 29 Jul 2016 22:46:39 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when compile the kenrel code, I happens to the following warn.
>> fs/reiserfs/ibalance.c:1156:2: warning: ___new_insert_key___ may be used
>> uninitialized in this function.
>> memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
>> ^
>> The patch just fix it to avoid the warn.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  fs/reiserfs/ibalance.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/reiserfs/ibalance.c b/fs/reiserfs/ibalance.c
>> index b751eea..512ce95 100644
>> --- a/fs/reiserfs/ibalance.c
>> +++ b/fs/reiserfs/ibalance.c
>> @@ -818,7 +818,7 @@ int balance_internal(struct tree_balance *tb,
>>  	int order;
>>  	int insert_num, n, k;
>>  	struct buffer_head *S_new;
>> -	struct item_head new_insert_key;
>> +	struct item_head uninitialized_var(new_insert_key);
>>  	struct buffer_head *new_insert_ptr = NULL;
>>  	struct item_head *new_insert_key_addr = insert_key;
> How do we know this isn't a real bug?  It isn't obvious to me that this
> warning is a false positive.
>
>
> .
>
  yes ,it maybe a real bug, I will resend it in v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
