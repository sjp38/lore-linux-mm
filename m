Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 25E376B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 07:40:21 -0500 (EST)
Received: by gxk13 with SMTP id 13so2256805gxk.14
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 04:40:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090210213502.7007.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090210210520.7004.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360902100431l4a5977e7p9c5152882f09dcf9@mail.gmail.com>
	 <20090210213502.7007.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Tue, 10 Feb 2009 21:40:19 +0900
Message-ID: <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
From: MinChan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 9:35 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hmm.. You're right.
>> As Johannes pointed out,
>> too many page shrinking can degrade resume performance.
>>
>> We need to bale out in shrink_all_memory.
>> Other people, thought ?
>
> shrink_all_zones() already have bale-out code ;)
>

Ahh.. I need to sleep. :(
Thanks. Kosaki-san.



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
