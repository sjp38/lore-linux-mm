Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B2C385F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 05:48:21 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so1395903rvb.26
        for <linux-mm@kvack.org>; Mon, 20 Apr 2009 02:49:06 -0700 (PDT)
Message-ID: <49EC44C6.1010603@gmail.com>
Date: Mon, 20 Apr 2009 17:47:50 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <20090420165529.61AB.A69D9226@jp.fujitsu.com> <49EC311D.4090605@gmail.com> <20090420181436.61AE.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090420181436.61AE.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro a??e??:
>> In the V4L2_MEMORY_USERPTR method, what I want to do is pin the 
>> anonymous pages in memory.
>>
>> I used to add the VM_LOCKED to vma associated with the pages.In my 
>> opinion, the pages will:
>> LRU_ACTIVE_ANON ---> LRU_INACTIVE_ANON---> LRU_UNEVICTABLE
>>
>> so the pages are pinned in memory.It was ugly, but it works I think.
>> Do you have any suggestions about this method?
>>     
>
> page migration (e.g. move_pages) ignore MLOCK.
> maybe, VM_LOCKED + gut()ed solved it partially :)
>
>   
My old codes used the get_user_pages()/VM_LOCKED just as you said.

I will read the  migration  code, I am not clear about why the gup() can 
stop the migraion.

> but, user process still can call munlock. it cause disaster.
> I still think -EINVAL is better.
>
>
>   
Why the user process call munlock? VLC or Mplayer do not call it, so I 
don't worry about that.

Our video card is still not on sale.So I can wait until the bug is fixed. :)
If there is no method to bypass the problem in future,I will return -EINVAL.

thanks
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
