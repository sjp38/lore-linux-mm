Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1829C6B006A
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 21:25:05 -0400 (EDT)
Received: by gxk21 with SMTP id 21so8023928gxk.10
        for <linux-mm@kvack.org>; Tue, 20 Oct 2009 18:25:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0f7b4023bee9b7ccc47998cd517d193c.squirrel@webmail-b.css.fujitsu.com>
References: <COL115-W535064AC2F576372C1BB1B9FC00@phx.gbl>
	 <0f7b4023bee9b7ccc47998cd517d193c.squirrel@webmail-b.css.fujitsu.com>
Date: Wed, 21 Oct 2009 09:25:04 +0800
Message-ID: <dc46d49c0910201825g1b3b3987w8f9002761a64166f@mail.gmail.com>
Subject: Re: [PATCH] try_to_unuse : remove redundant swap_count()
From: Bob Liu <yjfpb04@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Bo Liu <bo-liu@hotmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>
>> While comparing with swcount,it's no need to
>> call swap_count(). Just as int set_start_mm =
>> (*swap_map>= swcount) is ok.
>>
> Hmm ?
> *swap_map = (SWAP_HAS_CACHE) | count. What this change means ?
>

Sorry for the wrong format, I changed to gmail.
Because swcount is assigned value *swap_map not swap_count(*swap_map).
So I think here should compare with *swap_map not swap_count(*swap_map).

And refer to variable set_start_mm, it is inited also by comparing
*swap_map and swcount not swap_count(*swap_map) and swcount.
So I submited this patch.

> Anyway, swap_count() macro is removed by Hugh's patch (queued in -mm)
>
I am sorry for not notice that. So just forget about this patch.
Thanks!
-Bo

> Regards,
> -Kame
>
>> Signed-off-by: Bo Liu <bo-liu@hotmail.com>
>> ---
>>
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 63ce10f..2456fc6 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -1152,7 +1152,7 @@ static int try_to_unuse(unsigned int type)
>>       retval = unuse_mm(mm, entry, page);
>>      if (set_start_mm &&
>> -        swap_count(*swap_map) < swcount) {
>> +         ((*swap_map) < swcount)) {
>>       mmput(new_start_mm);
>>       atomic_inc(&mm->mm_users);
>>       new_start_mm = mm;
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
