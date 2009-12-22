Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A746C60044A
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 22:12:04 -0500 (EST)
Received: by pzk27 with SMTP id 27so1684341pzk.12
        for <linux-mm@kvack.org>; Mon, 21 Dec 2009 19:12:03 -0800 (PST)
Message-ID: <4B3038F9.9040701@gmail.com>
Date: Tue, 22 Dec 2009 11:11:53 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm : kill combined_idx
References: <1261366347-19232-1-git-send-email-shijie8@gmail.com> <20091221143139.7088a8d3.kamezawa.hiroyu@jp.fujitsu.com> <20091221194337.GA23345@csn.ul.ie>
In-Reply-To: <20091221194337.GA23345@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>> Hmm...As far as I remember, this code design was for avoiding "if".
>> Is this compare+jump is better than add+xor ?
>>
>>     
>
> Agreed. It's not clear that a compare+jump is cheaper than the add+xor.
> How often it's the case that the page is the higher or lower half of the
> buddy would depend heavily on the allocation/free pattern making it
> hard, if not possible, to predict which is the more common case.
>
>   
ok. thanks a lot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
