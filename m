Received: by wa-out-1112.google.com with SMTP id m28so686338wag.8
        for <linux-mm@kvack.org>; Sun, 20 Jul 2008 20:53:23 -0700 (PDT)
Message-ID: <2f11576a0807202053m858ef54r68e9ba637801e9e0@mail.gmail.com>
Date: Mon, 21 Jul 2008 12:53:23 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
In-Reply-To: <20080720184843.9f7b48e9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <87y73x4w6y.fsf@saeurebad.de>
	 <2f11576a0807201709q45aeec3cvb99b0049421245ae@mail.gmail.com>
	 <20080720184843.9f7b48e9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@saeurebad.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

>> in my experience,
>>   - page_referenced_one is performance critical point.
>>     you should test some benchmark.
>>   - its patch improved mmaped-copy performance about 5%.
>>     (Of cource, you should test in current -mm. MM code was changed widely)
>>
>> So, I'm looking for your test result :)
>
> The change seems logical and I queued it for 2.6.28.

Great.

> But yes, testing for what-does-this-improve is good and useful, but so
> is testing for what-does-this-worsen.  How do we do that in this case?

In general, page_referenced_one is important for reclaim throuput.
if crap page_referenced_one changing happend,
system reclaim throuput become slow down.

Of cource, I don't think this patch cause performance regression :-)

So, any benchmark with memcgroup memory restriction is good choice.

btw:
maybe, I will able to post mamped-copy improve mesurement of Johannes's patch
after OLS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
