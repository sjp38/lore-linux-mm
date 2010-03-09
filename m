Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 201206B009F
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 21:04:00 -0500 (EST)
Received: by pvh11 with SMTP id 11so1808357pvh.14
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 18:03:59 -0800 (PST)
Message-ID: <4B95AC52.1000502@gmail.com>
Date: Tue, 09 Mar 2010 10:02:58 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] shmem : remove redundant code
References: <1268040782-28561-1-git-send-email-shijie8@gmail.com> <1268064285.1254.6.camel@barrios-desktop>
In-Reply-To: <1268064285.1254.6.camel@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> On Mon, 2010-03-08 at 17:33 +0800, Huang Shijie wrote:
>    
>> The  prep_new_page() will call set_page_private(page, 0) to initiate
>> the page.
>>
>> So the code is redundant.
>>
>> Signed-off-by: Huang Shijie<shijie8@gmail.com>
>>      
> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>
>    
Thanks Minchan. :)
> Long time ago, nr_swapped named is meaningful as a comment at least.
> But as split page table lock is introduced in 4c21e2f2441, it was
> changed by just set_page_private.
> So even it's not meaningful any more as a comment, I think.
> So let's remove redundant code.
>
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
