Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 728E36B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 05:07:09 -0500 (EST)
Received: by bke17 with SMTP id 17so4285280bke.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 02:07:05 -0800 (PST)
Message-ID: <4EC62E46.6080503@openvz.org>
Date: Fri, 18 Nov 2011 14:07:02 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove struct reclaim_state
References: <20111118092806.21688.8662.stgit@zurg> <20111118095644.GJ7046@dastard>
In-Reply-To: <20111118095644.GJ7046@dastard>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Dave Chinner wrote:
> On Fri, Nov 18, 2011 at 01:28:06PM +0300, Konstantin Khlebnikov wrote:
>> Memory reclaimer want to know how much pages was reclaimed during shrinking slabs.
>> Currently there is special struct reclaim_state with single counter and pointer from
>> task-struct. Let's store counter direcly on task struct and account freed pages
>> unconditionally. This will reduce stack usage and simplify code in reclaimer and slab.
>>
>> Logic in do_try_to_free_pages() is slightly changed, but this is ok.
>> Nobody calls shrink_slab() explicitly before do_try_to_free_pages(),
>
> Except for drop_slab() and shake_page()....

Indeed, but they do not care about accounting reclaimed pages and
they do not call do_try_to_free_pages() after all.

>
> Cheers,
>
> Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
