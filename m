Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AC44D6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 19:02:47 -0400 (EDT)
Received: by qwa26 with SMTP id 26so828482qwa.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 16:02:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602182302.GA2802@random.random>
References: <20110530143109.GH19505@random.random>
	<20110530153748.GS5044@csn.ul.ie>
	<20110530165546.GC5118@suse.de>
	<20110530175334.GI19505@random.random>
	<20110531121620.GA3490@barrios-laptop>
	<20110531122437.GJ19505@random.random>
	<20110531133340.GB3490@barrios-laptop>
	<20110531141402.GK19505@random.random>
	<20110531143734.GB13418@barrios-laptop>
	<20110531143830.GC13418@barrios-laptop>
	<20110602182302.GA2802@random.random>
Date: Fri, 3 Jun 2011 08:02:35 +0900
Message-ID: <BANLkTi=d9q+W2LBiMYr0ND6XqSWGX3gMKg@mail.gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 3, 2011 at 3:23 AM, Andrea Arcangeli <aarcange@redhat.com> wrot=
e:
> On Tue, May 31, 2011 at 11:38:30PM +0900, Minchan Kim wrote:
>> > Yes. You find a new BUG.
>> > It seems to be related to this problem but it should be solved althoug=
h
>>
>> =C2=A0typo : It doesn't seem to be.
>
> This should fix it, but I doubt it matters for this problem.
>
> =3D=3D=3D
> Subject: mm: no page_count without a page pin
>
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> It's unsafe to run page_count during the physical pfn scan.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nitpick :
I want to remain "  /* the page is freed already. */" comment.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
