Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5A12C600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 00:18:59 -0500 (EST)
Received: by yxe36 with SMTP id 36so16021090yxe.11
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 21:18:57 -0800 (PST)
Message-ID: <4B417A37.7060001@gmail.com>
Date: Mon, 04 Jan 2010 13:18:47 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm : add check for the return value
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com>	<20100104122138.f54b7659.minchan.kim@barrios-desktop>	<4B416A28.70806@gmail.com> <20100104134827.ce642c11.minchan.kim@barrios-desktop>
In-Reply-To: <20100104134827.ce642c11.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> I think the branch itself could not a big deal but 'likely'.
>
> Why I suggest is that now 'if (!page)' don't have 'likely'.
> As you know, 'likely' make the code relocate for reducing code footprint.
>
> Why? It was just mistake or doesn't need it?
>
>    
I think the CPU will CACHE the `likely' code, and make it runs fast.

IMHO, "if (unlikely(page == NULL)) " is better then "if (!page)" ,just 
like the
code in rmqueue_bulk().

> I think Mel does know it.
>
>    
wait for Mel's response.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
