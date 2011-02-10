Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A124E8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:39:01 -0500 (EST)
Received: by iwc10 with SMTP id 10so1314100iwc.14
        for <linux-mm@kvack.org>; Thu, 10 Feb 2011 05:38:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1297343929.1449.3.camel@leonhard>
References: <1297338408-3590-1-git-send-email-namhyung@gmail.com>
	<AANLkTikEigbPsNMqqkmixYbCfD7Dz12YMcW2+GZbhUQq@mail.gmail.com>
	<1297343929.1449.3.camel@leonhard>
Date: Thu, 10 Feb 2011 22:38:59 +0900
Message-ID: <AANLkTimcLgsdEm6XKESc34Z=nsJkZqz8H1jR-ARZo_Gq@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: handle simple case in free_pcppages_bulk()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 10:18 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> 2011-02-10 (=EB=AA=A9), 22:10 +0900, Minchan Kim:
>> Hello Namhyung,
>>
>
> Hi Minchan,
>
>
>> On Thu, Feb 10, 2011 at 8:46 PM, Namhyung Kim <namhyung@gmail.com> wrote=
:
>> > Now I'm seeing that there are some cases to free all pages in a
>> > pcp lists. In that case, just frees all pages in the lists instead
>> > of being bothered with round-robin lists traversal.
>>
>> I though about that but I didn't send the patch.
>> That's because many cases which calls free_pcppages_bulk(,
>> pcp->count,..) are slow path so it adds comparison overhead on fast
>> path while it loses the effectiveness in slow path.
>>
>
> Hmm.. How about adding unlikely() then? Doesn't it help much here?

Yes. It would help but I am not sure how much it is.
AFAIR, when Mel submit the patch, he tried to prove the effectiveness
with some experiment and profiler.
I think if you want it really, we might need some number.
I am not sure it's worth.




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
