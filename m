Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 011F18D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:58:19 -0500 (EST)
Received: by iwn41 with SMTP id 41so654717iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 16:58:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101202092921.1570.A69D9226@jp.fujitsu.com>
References: <20101201155854.GA3372@barrios-desktop>
	<20101202090952.1567.A69D9226@jp.fujitsu.com>
	<20101202092921.1570.A69D9226@jp.fujitsu.com>
Date: Thu, 2 Dec 2010 09:58:18 +0900
Message-ID: <AANLkTik5HW6XgTNwGk2_Q36T0RpGMaCouZcTT2L5nfCd@mail.gmail.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 2, 2010 at 9:29 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > It might work well. but I don't like such a coding that kswapd_try_to_=
sleep's
>> > eturn value is order. It doesn't look good to me and even no comment. =
Hmm..
>> >
>> > How about this?
>> > If you want it, feel free to use it.
>> > If you insist on your coding style, I don't have any objection.
>> > Then add My Reviewed-by.
>> >
>> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>>
>> I'm ok this.
>>
>> =A0 =A0 =A0 Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com=
>
>>
>>
>> Thanks.
>>
>
> Please consider rensend a patch with full patch description. Of cource,
> you need to rebase this on top Mel's patch.
>
> Plus, please don't remove Shaohua's reported-by tag. It's important line
> than my code. Please respect good bug finder.

I don't have a thought to intercept Shaohua and Your's credit.
Just a review so I hoped you send the patch with adding my signed-off
or reviewed-by.

Okay. I will resend it with full-description and you guys's signed-off.
But before that, We have to discuss Shaohua's argue about _safety_.

> Thanks.
>
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
