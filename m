Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 21FBD6B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 23:46:55 -0400 (EDT)
Received: by iwn33 with SMTP id 33so7571776iwn.14
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 20:46:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C7C6959.3030801@redhat.com>
References: <AANLkTi==mQh31PzuNa1efH2WM1s-VPKyZX0f5iwb54PD@mail.gmail.com>
	<AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com>
	<20100831095140.87C7.A69D9226@jp.fujitsu.com>
	<AANLkTin4-NomOoNFYCKgi7oE+MCUiC0o0ftAkOwLKez_@mail.gmail.com>
	<4C7C6959.3030801@redhat.com>
Date: Tue, 31 Aug 2010 12:46:53 +0900
Message-ID: <AANLkTik=6kRdz0LJnRRhddW_Lp8osis-4Y7EGc4u5x0z@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 11:30 AM, Rik van Riel <riel@redhat.com> wrote:
> On 08/30/2010 09:23 PM, Minchan Kim wrote:
>
>> Ying's one and mine both has a same effect.
>> Only difference happens swap is full. My version maintains old
>> behavior but Ying's one changes the behavior. I admit swap full is
>> rare event but I hoped not changed old behavior if we doesn't find any
>> problem.
>> If kswapd does aging when swap full happens, is it a problem?
>
> It may be a good thing, since swap will often be freed again
> (when something is swapped in, or exits).
>
> Having some more anonymous pages sit on the inactive list
> gives them a chance to get used again, potentially giving
> us a better chance of preserving the working set when swap
> is full or near full a lot of the time.

Do you mean we would be better to do background aging when swap is full?
I wanted it. So I used total_swap_pages to protect working set when
swap is full.
But Ying and KOSAKI's don't like it since it makes code inconsistent
or not simply.
And I agree it's rare event as KOSAKI mentioned.

Hmm... What do you think about it?

If you don't mind, I will resend latest version(use nr_swap_page usage
and compile out inactive_anon_is_low in case of !CONFIG_SWAP).


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
