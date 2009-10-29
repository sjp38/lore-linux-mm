Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 39C926B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 21:55:32 -0400 (EDT)
Received: by pxi5 with SMTP id 5so942275pxi.12
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 18:55:30 -0700 (PDT)
Message-ID: <4AE8F60E.9020700@gmail.com>
Date: Thu, 29 Oct 2009 09:55:26 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap : simplify the code for try_to_unmap_file
References: <1256019670-23293-1-git-send-email-shijie8@gmail.com> <20091028220431.95F8.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091028220431.95F8.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>> Just simplify the code when the mlocked is true.
>>
>> Signed-off-by: Huang Shijie <shijie8@gmail.com>
>> ---
>>  mm/rmap.c |    5 +----
>>  1 files changed, 1 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index dd43373..c57c3b6 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1100,13 +1100,10 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>>  		if (ret == SWAP_MLOCK) {
>>  			mlocked = try_to_mlock_page(page, vma);
>>  			if (mlocked)
>> -				break;  /* stop if actually mlocked page */
>> +				goto out;  /* stop if actually mlocked page */
>>  		}
>>  	}
>>  
>> -	if (mlocked)
>> -		goto out;
>> -
>>  	if (list_empty(&mapping->i_mmap_nonlinear))
>>  		goto out;
>>     
>
> Did anyone reviewed this patch?
> Anyway,
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
>   
thanks :)
> Huang, I'm sorry for the delaying. I was attend to JLS and I couldn't
> review long time.
>
>
>   
Not at all.I forgeted the JLS when I sent the two tiny patchs.
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
