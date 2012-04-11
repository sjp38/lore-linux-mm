Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id C3B7E6B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:10:14 -0400 (EDT)
Received: by yhr47 with SMTP id 47so851034yhr.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 11:10:13 -0700 (PDT)
Message-ID: <4F85C909.8040905@gmail.com>
Date: Wed, 11 Apr 2012 14:10:17 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] remove swap token code
References: <20120409113201.6dff571a@annuminas.surriel.com> <20120411014855.GA1929@cmpxchg.org>
In-Reply-To: <20120411014855.GA1929@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(4/10/12 9:48 PM), Johannes Weiner wrote:
> On Mon, Apr 09, 2012 at 11:32:01AM -0400, Rik van Riel wrote:
>> The swap token code no longer fits in with the current VM model.
>> It does not play well with cgroups or the better NUMA placement
>> code in development, since we have only one swap token globally.
>>
>> It also has the potential to mess with scalability of the system,
>> by increasing the number of non-reclaimable pages on the active
>> and inactive anon LRU lists.
>>
>> Last but not least, the swap token code has been broken for a
>> year without complaints.  This suggests we no longer have much
>> use for it.
>>
>> The days of sub-1G memory systems with heavy use of swap are
>> over. If we ever need thrashing reducing code in the future,
>> we will have to implement something that does scale.
>>
>> Signed-off-by: Rik van Riel<riel@redhat.com>
>
> Acked-by: Johannes Weiner<hannes@cmpxchg.org>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I really think swap token is sane. but now (after merging Johannes's memcg naturalization)
it don't work and we don't have a reason to maintain _current_ implementaion.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
