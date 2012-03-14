Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 20D626B004D
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 06:42:40 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2076727yen.14
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 03:42:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1203131345290.27008@chino.kir.corp.google.com>
References: <1331652803-3092-1-git-send-email-consul.kautuk@gmail.com>
	<alpine.DEB.2.00.1203131345290.27008@chino.kir.corp.google.com>
Date: Wed, 14 Mar 2012 16:12:39 +0530
Message-ID: <CAFPAmTSUuWW1gc5U=CB1MEoWqEWoDoAkay0svv--qF4n3cOcdg@mail.gmail.com>
Subject: Re: [PATCH 2/2] page_alloc: Remove argument to find_zone_movable_pfns_for_nodes
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 14, 2012 at 2:17 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Tue, 13 Mar 2012, Kautuk Consul wrote:
>
>> The find_zone_movable_pfns_for_nodes() function does not utiilize
>> the argument to it.
>>
>
> It could, though, if we made it to do so.
>
>> Removing this argument from the function prototype as well as its
>> caller, i.e. free_area_init_nodes().
>>
>
> Not sure if we'd ever want it or not for other purposes, but
> find_zone_movable_pfns_for_nodes() could easily be made to use the passed
> in array rather than zone_movable_pfn in file scope directly. =A0That see=
ms
> to be why it took an argument in the first place.
>

No function is calling this function and I just wanted to remove the
slight overhead of passing an
argument which does not get used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
