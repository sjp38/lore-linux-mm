Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 93B396B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 13:32:29 -0400 (EDT)
Received: by yenm7 with SMTP id m7so2516009yen.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 10:32:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <66ea94b0-2e40-44d1-9621-05f2a8257298@default>
References: <66ea94b0-2e40-44d1-9621-05f2a8257298@default>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 10 May 2012 13:32:07 -0400
Message-ID: <CAHGf_=pDKciwPX4G0yJjzc0xmuqiSg=yHB20btJSYhN9cA7gug@mail.gmail.com>
Subject: Re: is there a "lru_cache_add_anon_tail"?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

On Thu, May 10, 2012 at 12:13 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> (Still working on allowing zcache to "evict" swap pages...)
>
> Apologies if I got head/tail reversed as used by the
> lru queues... the "directional sense" of the queues is
> not obvious so I'll describe using different terminology...
>
> If I have an anon page and I would like to add it to
> the "reclaim soonest" end of the queue instead of the
> "most recently used so don't reclaim it for a long time"
> end of the queue, does an equivalent function similar to
> lru_cache_add_anon(page) exist?
>

AFAIK, no exist.
rotate_reclaimable_page() has similar requirement, but I doubt
you can reuse it. maybe you need new function by yourself.

But note, many people dislike add_anon_tail feature. -ck patch had
swap prefetch patch and it made performance decrease. I'm not
sure it is good improvemnt for zcache....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
