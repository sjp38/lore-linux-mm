Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 66C0D6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 06:44:05 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2038493ghr.14
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 03:44:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTSUuWW1gc5U=CB1MEoWqEWoDoAkay0svv--qF4n3cOcdg@mail.gmail.com>
References: <1331652803-3092-1-git-send-email-consul.kautuk@gmail.com>
	<alpine.DEB.2.00.1203131345290.27008@chino.kir.corp.google.com>
	<CAFPAmTSUuWW1gc5U=CB1MEoWqEWoDoAkay0svv--qF4n3cOcdg@mail.gmail.com>
Date: Wed, 14 Mar 2012 16:14:04 +0530
Message-ID: <CAFPAmTTW4tYL0NP6JSpPoHkT-BxPjHHwJpJtkxQdOW_Bp=hwrA@mail.gmail.com>
Subject: Re: [PATCH 2/2] page_alloc: Remove argument to find_zone_movable_pfns_for_nodes
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 14, 2012 at 4:12 PM, Kautuk Consul <consul.kautuk@gmail.com> wr=
ote:
> On Wed, Mar 14, 2012 at 2:17 AM, David Rientjes <rientjes@google.com> wro=
te:
>> On Tue, 13 Mar 2012, Kautuk Consul wrote:
>>
>>> The find_zone_movable_pfns_for_nodes() function does not utiilize
>>> the argument to it.
>>>
>>
>> It could, though, if we made it to do so.
>>
>>> Removing this argument from the function prototype as well as its
>>> caller, i.e. free_area_init_nodes().
>>>
>>
>> Not sure if we'd ever want it or not for other purposes, but
>> find_zone_movable_pfns_for_nodes() could easily be made to use the passe=
d
>> in array rather than zone_movable_pfn in file scope directly. =A0That se=
ems
>> to be why it took an argument in the first place.
>>
>
> No function is calling this function and I just wanted to remove the
> slight overhead of passing an
> argument which does not get used.

Sorry.. I meant : no other function oter than free_area_init_nodes()
calls this function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
