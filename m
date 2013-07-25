Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id F21EA6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 14:14:22 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id g12so5030519oah.25
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:14:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1ciCDJeBqZv1gHNpQ2VVyDRAVF9_au+fo2dwVvLqnkygA@mail.gmail.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com> <CAA_GA1ciCDJeBqZv1gHNpQ2VVyDRAVF9_au+fo2dwVvLqnkygA@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 25 Jul 2013 14:14:01 -0400
Message-ID: <CAHGf_=oSiz8TKhrz9unxGSkxO10jveae9n+U8GPDoppe2jmYxw@mail.gmail.com>
Subject: Re: Possible deadloop in direct reclaim?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Lisa Du <cldu@marvell.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>

> How about replace the checking in kswapd_shrink_zone()?
>
> @@ -2824,7 +2824,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
>         /* Account for the number of pages attempted to reclaim */
>         *nr_attempted += sc->nr_to_reclaim;
>
> -       if (nr_slab == 0 && !zone_reclaimable(zone))
> +       if (sc->nr_reclaimed == 0 && !zone_reclaimable(zone))
>                 zone->all_unreclaimable = 1;
>
>         zone_clear_flag(zone, ZONE_WRITEBACK);
>
>
> I think the current check is wrong, reclaimed a slab doesn't mean
> reclaimed a page.

The code is correct, at least, it works as intentional. page reclaim
status is checked by zone_reclaimable() and slab shrinking status is
checked by nr_slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
