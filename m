Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 516FE900113
	for <linux-mm@kvack.org>; Sun,  1 May 2011 11:09:28 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3385268qwa.14
        for <linux-mm@kvack.org>; Sun, 01 May 2011 08:09:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110501222117.75E8.A69D9226@jp.fujitsu.com>
References: <20110428105027.GT4658@suse.de>
	<BANLkTi=bMm+iyO23+16FxK__V1-aM50zWQ@mail.gmail.com>
	<20110501222117.75E8.A69D9226@jp.fujitsu.com>
Date: Mon, 2 May 2011 00:09:26 +0900
Message-ID: <BANLkTi=u-a+L_AGoM+_yufuBBAwPnVG0Zw@mail.gmail.com>
Subject: Re: [RFC 5/8] compaction: remove active list counting
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Sun, May 1, 2011 at 10:19 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, Apr 28, 2011 at 7:50 PM, Mel Gorman <mgorman@suse.de> wrote:
>> > On Wed, Apr 27, 2011 at 01:25:22AM +0900, Minchan Kim wrote:
>> >> acct_isolated of compaction uses page_lru_base_type which returns onl=
y
>> >> base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTI=
VE_FILE.
>> >> So it's pointless to add lru[LRU_ACTIVE_[ANON|FILE]] to get sum.
>> >>
>> >> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >> Cc: Mel Gorman <mgorman@suse.de>
>> >> Cc: Rik van Riel <riel@redhat.com>
>> >> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> >
>> > hmm, isolate_migratepages() is doing a linear scan of PFNs and is
>> > calling __isolate_lru_page(..ISOLATE_BOTH..). Using page_lru_base_type
>> > happens to work because we're only interested in the number of isolate=
d
>> > pages and your patch still covers that. Using page_lru might be more
>> > accurate in terms of accountancy but does not seem necessary.
>>
>> True.
>>
>> >
>> > Adding a comment explaining why we account for it as inactive and why
>> > that's ok would be nice although I admit this is something I should ha=
ve
>> > done when acct_isolated() was introduced.
>>
>> When Kame pointed out comment, I wanted to avoid unnecessary comment
>> so decided changing it with page_lru although it adds overhead a
>> little bit. But Hannes, you and maybe Kame don't want it. I don't mind
>> adding comment.
>> Okay. fix it in next version.
>
> Or
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int count[2];
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(page, &cc->migratepages, l=
ru) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count[page_is_file=
_cache(page)]++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> is also clear to me.
>

That's very clear to me, too.
Thanks, KOSAKI.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
