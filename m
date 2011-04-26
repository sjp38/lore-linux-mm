Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEF49000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:28:56 -0400 (EDT)
Received: by wyf19 with SMTP id 19so376822wyf.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:28:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426092029.GA27053@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
	<BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
	<BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
	<20110426062535.GB19717@localhost>
	<BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
	<20110426063421.GC19717@localhost>
	<BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
	<20110426092029.GA27053@localhost>
Date: Tue, 26 Apr 2011 18:28:53 +0900
Message-ID: <BANLkTiknvQ-dmOB4vEfYeC-wmFJL3A0ekA@mail.gmail.com>
Subject: Re: readahead and oom
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>

On Tue, Apr 26, 2011 at 6:20 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Minchan,
>
>> > +static inline struct page *page_cache_alloc_cold_noretry(struct addre=
ss_space *x)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 return __page_cache_alloc(mapping_gfp_mask(x)|_=
_GFP_COLD|__GFP_NORETRY);
>>
>> It makes sense to me but it could make a noise about page allocation
>> failure. I think it's not desirable.
>> How about adding __GFP_NOWARAN?
>
> Yeah it makes sense. Here is the new version.
>
> Thanks,
> Fengguang
> ---
> Subject: readahead: readahead page allocations is OK to fail
> Date: Tue Apr 26 14:29:40 CST 2011
>
> Pass __GFP_NORETRY|__GFP_NOWARN for readahead page allocations.
>
> readahead page allocations are completely optional. They are OK to
> fail and in particular shall not trigger OOM on themselves.
>
> Reported-by: Dave Young <hidave.darkstar@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
