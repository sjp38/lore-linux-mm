Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 804FE6B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 21:25:53 -0500 (EST)
Received: by qabg40 with SMTP id g40so8285995qab.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 18:25:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111230151556.GF15729@suse.de>
References: <4EFA87E4.8040609@gmail.com>
	<20111230151556.GF15729@suse.de>
Date: Mon, 2 Jan 2012 11:25:52 +0900
Message-ID: <CAH9JG2XyixB5mVDQrcLSEfUFsuKt+7j8Jvq7ihuz1x2PJXYJ-A@mail.gmail.com>
Subject: Re: [PATCH] mm/migrate.c: remove the unused macro lru_to_page
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Wang Sheng-Hui <shhuiw@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/31/11, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Dec 28, 2011 at 11:07:16AM +0800, Wang Sheng-Hui wrote:
>> lru_to_page is not used in mm/migrate.c. Drop it.
>>
>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>
> Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> --
> Mel Gorman
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
