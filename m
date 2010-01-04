Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 51BF3600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 19:47:13 -0500 (EST)
Received: by pzk27 with SMTP id 27so8333253pzk.12
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 16:47:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100104084347.c36d9855.kamezawa.hiroyu@jp.fujitsu.com>
References: <ceeec51bdc2be64416e05ca16da52a126b598e17.1258773030.git.minchan.kim@gmail.com>
	 <ae2928fe7bb3d94a7ca18d3b3274fdfeb009803a.1258773030.git.minchan.kim@gmail.com>
	 <4B38876F.6010204@gmail.com>
	 <alpine.LSU.2.00.0912301619500.3369@sister.anvils>
	 <20100104084347.c36d9855.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 4 Jan 2010 09:47:11 +0900
Message-ID: <28c262361001031647r602fcdbeve56dbf4da4e31254@mail.gmail.com>
Subject: Re: [PATCH 2/3 -mmotm-2009-12-10-17-19] Count zero page as file_rss
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 4, 2010 at 8:43 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 30 Dec 2009 16:49:52 +0000 (GMT)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
>
>> > >
>> > > Kame reported following as
>> > > "Before starting zero-page works, I checked "questions" in lkml and
>> > > found some reports that some applications start to go OOM after zero=
-page
>> > > removal.
>> > >
>> > > For me, I know one of my customer's application depends on behavior =
of
>> > > zero page (on RHEL5). So, I tried to add again it before RHEL6 becau=
se
>> > > I think removal of zero-page corrupts compatibility."
>> > >
>> > > So how about adding zero page as file_rss again for compatibility?
>>
>> I think not.
>>
>> KAMEZAWA-san can correct me (when he returns in the New Year) if I'm
>> wrong, but I don't think his customer's OOMs had anything to do with
>> whether the ZERO_PAGE was counted in file_rss or not: the OOMs came
>> from the fact that many pages were being used up where just the one
>> ZERO_PAGE had been good before. =C2=A0Wouldn't he have complained if the
>> zero_pfn patches hadn't solved that problem?
>>
>> You are right that I completely overlooked the issue of whether to
>> include the ZERO_PAGE in rss counts (now being a !vm_normal_page,
>> it was just natural to leave it out); and I overlooked the fact that
>> it used to be counted into file_rss in the old days (being !PageAnon).
>>
>> So I'm certainly at fault for that, and thank you for bringing the
>> issue to attention; but once considered, I can't actually see a good
>> reason why we should add code to count ZERO_PAGEs into file_rss now.
>> And if this patch falls, then 1/3 and 3/3 would fall also.
>>
>> And the patch below would be incomplete anyway, wouldn't it?
>> There would need to be a matching change to zap_pte_range(),
>> but I don't see that.
>>
>> We really don't want to be adding more and more ZERO_PAGE/zero_pfn
>> tests around the place if we can avoid them: KOSAKI-san has a strong
>> argument for adding such a test in kernel/futex.c, but I don't the
>> argument here.
>>
>
> I agree that ZERO_PAGE shouldn't be counted as rss. Now, I feel that old
> counting method(in old zero-page implementation) was bad.
>
> Minchan-san, I'm sorry for noise.

That's all right.
It was my mistake.

I will drop this and repost Matt and Hugh's ACK version.
Thanks for all. :)

>
> Thanks,
> -Kame
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
