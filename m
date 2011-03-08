Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D454D8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 00:17:25 -0500 (EST)
Received: by iwl42 with SMTP id 42so6161394iwl.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 21:17:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110308134633.7EBF.A69D9226@jp.fujitsu.com>
References: <AANLkTikxoONF16WduKaRKpTFKkZbAR==UA1_a+3qzRV2@mail.gmail.com>
	<1299559453.2337.30.camel@sli10-conroe>
	<20110308134633.7EBF.A69D9226@jp.fujitsu.com>
Date: Tue, 8 Mar 2011 14:17:24 +0900
Message-ID: <AANLkTikBKemiS1aJB-MrHXwefHxKs2gGX6w=J1oQqJd-@mail.gmail.com>
Subject: Re: [PATCH 2/2 v3]mm: batch activate_page() to reduce lock contention
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 8, 2011 at 1:47 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > > +#ifdef CONFIG_SMP
>> > > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
>> >
>> > Why do we have to handle SMP and !SMP?
>> > We have been not separated in case of pagevec using in swap.c.
>> > If you have a special reason, please write it down.
>> this is to reduce memory footprint as suggested by akpm.
>>
>> Thanks,
>> Shaohua
>
> Hi Shaouhua,
>
> I agree with you. But, please please avoid full quote. I don't think
> it is so much difficult work. ;-)

I didn't want to add new comment in the code but want to know why we
have to care of activate_page_pvecs specially. I think it's not a
matter of difficult work or easy work. If new thing is different with
existing things, at least some comment in description makes review
easy.

If it's memory footprint issue, should we care of other pagevec to
reduce memory footprint in non-smp? If it is, it would be a TODO list
for consistency and memory footprint.

>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
