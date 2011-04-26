Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EE31E9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 06:18:59 -0400 (EDT)
Received: by gxk23 with SMTP id 23so239123gxk.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:18:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTiknvQ-dmOB4vEfYeC-wmFJL3A0ekA@mail.gmail.com>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
	<BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
	<BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
	<20110426062535.GB19717@localhost>
	<BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
	<20110426063421.GC19717@localhost>
	<BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
	<20110426092029.GA27053@localhost>
	<BANLkTiknvQ-dmOB4vEfYeC-wmFJL3A0ekA@mail.gmail.com>
Date: Tue, 26 Apr 2011 13:18:55 +0300
Message-ID: <BANLkTikR0nsGaXgLvGQ_a01JeK0LgLxT_Q@mail.gmail.com>
Subject: Re: readahead and oom
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>

On Tue, Apr 26, 2011 at 12:28 PM, Minchan Kim <minchan.kim@gmail.com> wrote=
:
> On Tue, Apr 26, 2011 at 6:20 PM, Wu Fengguang <fengguang.wu@intel.com> wr=
ote:
>> Minchan,
>>
>>> > +static inline struct page *page_cache_alloc_cold_noretry(struct addr=
ess_space *x)
>>> > +{
>>> > + =A0 =A0 =A0 return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COL=
D|__GFP_NORETRY);
>>>
>>> It makes sense to me but it could make a noise about page allocation
>>> failure. I think it's not desirable.
>>> How about adding __GFP_NOWARAN?
>>
>> Yeah it makes sense. Here is the new version.
>>
>> Thanks,
>> Fengguang
>> ---
>> Subject: readahead: readahead page allocations is OK to fail
>> Date: Tue Apr 26 14:29:40 CST 2011
>>
>> Pass __GFP_NORETRY|__GFP_NOWARN for readahead page allocations.
>>
>> readahead page allocations are completely optional. They are OK to
>> fail and in particular shall not trigger OOM on themselves.
>>
>> Reported-by: Dave Young <hidave.darkstar@gmail.com>
>> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
