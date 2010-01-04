Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 88031600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 01:06:56 -0500 (EST)
Received: by pzk27 with SMTP id 27so8460182pzk.12
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 22:06:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B417A37.7060001@gmail.com>
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com>
	 <20100104122138.f54b7659.minchan.kim@barrios-desktop>
	 <4B416A28.70806@gmail.com>
	 <20100104134827.ce642c11.minchan.kim@barrios-desktop>
	 <4B417A37.7060001@gmail.com>
Date: Mon, 4 Jan 2010 15:06:54 +0900
Message-ID: <28c262361001032206m6b102f85wed64ae31fd5b06d5@mail.gmail.com>
Subject: Re: [PATCH] mm : add check for the return value
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 4, 2010 at 2:18 PM, Huang Shijie <shijie8@gmail.com> wrote:
>
>> I think the branch itself could not a big deal but 'likely'.
>>
>> Why I suggest is that now 'if (!page)' don't have 'likely'.
>> As you know, 'likely' make the code relocate for reducing code footprint.
>>
>> Why? It was just mistake or doesn't need it?
>>
>>
>
> I think the CPU will CACHE the `likely' code, and make it runs fast.

I think so.

>
> IMHO, "if (unlikely(page == NULL)) " is better then "if (!page)" ,just like
> the
> code in rmqueue_bulk().
>> I think Mel does know it.
>>
>>
>
> wait for Mel's response.

Yes.
Regardless of Kosaki's patch, there is a issue about likely/unlinkely usage.

>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
