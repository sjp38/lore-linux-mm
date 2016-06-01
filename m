Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF3B6B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 11:24:45 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id um11so14579992pab.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:24:45 -0700 (PDT)
Received: from lists.s-osg.org (lists.s-osg.org. [54.187.51.154])
        by mx.google.com with ESMTP id r4si50169804pfr.48.2016.06.01.08.24.44
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 08:24:44 -0700 (PDT)
Subject: Re: [PATCH] kasan: change memory hot-add error messages to info
 messages
References: <1464794430-5486-1-git-send-email-shuahkh@osg.samsung.com>
 <CAG_fn=UbgEkJ5rv0Em9nNthLOWqy7BZ7y9ZU3ub8QTF6t_VpYw@mail.gmail.com>
From: Shuah Khan <shuahkh@osg.samsung.com>
Message-ID: <574EFE3A.8030408@osg.samsung.com>
Date: Wed, 1 Jun 2016 09:24:42 -0600
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UbgEkJ5rv0Em9nNthLOWqy7BZ7y9ZU3ub8QTF6t_VpYw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, aryabinin@virtuozzo.com
Cc: Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shuah Khan <shuahkh@osg.samsung.com>

On 06/01/2016 09:22 AM, Alexander Potapenko wrote:
> On Wed, Jun 1, 2016 at 5:20 PM, Shuah Khan <shuahkh@osg.samsung.com> wrote:
>> Change the following memory hot-add error messages to info messages. There
>> is no need for these to be errors.
>>
>> [    8.221108] kasan: WARNING: KASAN doesn't support memory hot-add
>> [    8.221117] kasan: Memory hot-add will be disabled
>>
>> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
>> ---
>> Note: This is applicable to 4.6 stable releases.
>>
>>  mm/kasan/kasan.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 18b6a2b..28439ac 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -763,8 +763,8 @@ static int kasan_mem_notifier(struct notifier_block *nb,
>>
>>  static int __init kasan_memhotplug_init(void)
>>  {
>> -       pr_err("WARNING: KASAN doesn't support memory hot-add\n");
>> -       pr_err("Memory hot-add will be disabled\n");
>> +       pr_info("WARNING: KASAN doesn't support memory hot-add\n");
>> +       pr_info("Memory hot-add will be disabled\n");
> No objections, but let's wait for Andrey.

Thanks. Fixing Andrey's address. I had a cut and paste error. Sorry.

>>         hotplug_memory_notifier(kasan_mem_notifier, 0);
>>
>> --
>> 2.7.4
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
