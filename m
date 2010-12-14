Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 122476B0093
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 21:36:13 -0500 (EST)
Received: by iyj17 with SMTP id 17so77600iyj.14
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 18:36:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87lj3t30a9.fsf@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
	<20101208170504.1750.A69D9226@jp.fujitsu.com>
	<AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
	<87oc8wa063.fsf@gmail.com>
	<AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com>
	<20101213153105.GA2344@barrios-desktop>
	<87lj3t30a9.fsf@gmail.com>
Date: Tue, 14 Dec 2010 11:36:12 +0900
Message-ID: <AANLkTikT_HNvuBR0J-2COgB54gquj2FineOjkzU+mt6_@mail.gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Tue, Dec 14, 2010 at 5:06 AM, Ben Gamari <bgamari.foss@gmail.com> wrote:
> On Tue, 14 Dec 2010 00:31:05 +0900, Minchan Kim <minchan.kim@gmail.com> w=
rote:
>> In summary, my patch enhances a littie bit about elapsed time in
>> memory pressure environment and enhance reclaim effectivness(reclaim/rec=
laim)
>> with x2. It means reclaim latency is short and doesn't evict working set
>> pages due to invalidated pages.
>>
> Thank you very much for this testing! I'm very sorry I've been unable to
> contribute more recently. My last exam is on Wednesday and besides some
> grading that is the end of the semester. =A0Is there anything you would

No worry. I hope you have great grade in your exam. :)

> like me to do? Perhaps reproducing these results on my setup would be
> useful?

Thanks very much if you do.

>
>> Look at reclaim effectivness. Patched rsync enhances x2 about reclaim
>> effectiveness and compared to mmotm-12-03, mmotm-12-03-fadvise enhances
>> 3 minute about elapsed time in stress environment.
>> I think it's due to reduce scanning, reclaim overhead.
>>
> Good good. This looks quite promising.

Thanks, Ben.

>
>> In no-stress enviroment, fadivse makes program little bit slow.
>> I think because there are many pgfault. I don't know why it happens.
>> Could you guess why it happens?
>>
> Hmm, nothing comes to mind. As I've said in the past, rsync should
> require each page only once. Perhaps perf might offer some insight into
> where this time is being spent?

Maybe. I will have a plan to look into that.

>
> - Ben
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
