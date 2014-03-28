Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 128F76B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 10:32:59 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so4124364eek.35
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 07:32:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ma4si2253031wic.20.2014.03.28.07.32.57
        for <linux-mm@kvack.org>;
        Fri, 28 Mar 2014 07:32:58 -0700 (PDT)
Message-ID: <533587FD.7000006@redhat.com>
Date: Fri, 28 Mar 2014 10:32:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Adding compression before/above swapcache
References: <CALZtONDiOdYSSu02Eo78F4UL5OLTsk-9MR1hePc-XnSujRuvfw@mail.gmail.com> <20140327222605.GB16495@medulla.variantweb.net> <CALZtONDBNzL_S+UUxKgvNjEYu49eM5Fc2yJ37dJ8E+PEK+C7qg@mail.gmail.com>
In-Reply-To: <CALZtONDBNzL_S+UUxKgvNjEYu49eM5Fc2yJ37dJ8E+PEK+C7qg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 03/28/2014 08:36 AM, Dan Streetman wrote:

> Well my general idea was to modify shrink_page_list() so that instead
> of calling add_to_swap() and then pageout(), anonymous pages would be
> added to a compressed cache.  I haven't worked out all the specific
> details, but I am initially thinking that the compressed cache could
> simply repurpose incoming pages to use as the compressed cache storage
> (using its own page mapping, similar to swap page mapping), and then
> add_to_swap() the storage pages when the compressed cache gets to a
> certain size.  Pages that don't compress well could just bypass the
> compressed cache, and get sent the current route directly to
> add_to_swap().

That sounds a lot like what zswap does. How is your
proposal different?

And, is there an easier way to implement that difference? :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
