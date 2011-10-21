Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA036B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 02:54:31 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so4567557vcb.14
        for <linux-mm@kvack.org>; Thu, 20 Oct 2011 23:54:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201110200830.22062.pluto@agmk.net>
References: <201110122012.33767.pluto@agmk.net>
	<CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com>
	<alpine.LSU.2.00.1110191234570.6900@sister.anvils>
	<201110200830.22062.pluto@agmk.net>
Date: Fri, 21 Oct 2011 14:54:29 +0800
Message-ID: <CAPQyPG5c1ADteP_rA2JRqLz88s7ZP_vWAKV-dp2hCSM9bRCpmg@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-2?Q?Pawe=B3_Sikora?= <pluto@agmk.net>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

2011/10/20 Pawe=C5=82 Sikora <pluto@agmk.net>:
> On Wednesday 19 of October 2011 21:42:15 Hugh Dickins wrote:
>> On Wed, 19 Oct 2011, Linus Torvalds wrote:
>> > On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman <mgorman@suse.de> wrote:
>> > >
>> > > My vote is with the migration change. While there are occasionally
>> > > patches to make migration go faster, I don't consider it a hot path.
>> > > mremap may be used intensively by JVMs so I'd loathe to hurt it.
>> >
>> > Ok, everybody seems to like that more, and it removes code rather than
>> > adds it, so I certainly prefer it too. Pawel, can you test that other
>> > patch (to mm/migrate.c) that Hugh posted? Instead of the mremap vma
>> > locking patch that you already verified for your setup?
>> >
>> > Hugh - that one didn't have a changelog/sign-off, so if you could
>> > write that up, and Pawel's testing is successful, I can apply it...
>> > Looks like we have acks from both Andrea and Mel.
>>
>> Yes, I'm glad to have that input from Andrea and Mel, thank you.
>>
>> Here we go. =C2=A0I can't add a Tested-by since Pawel was reporting on t=
he
>> alternative patch, but perhaps you'll be able to add that in later.
>>
>> I may have read too much into Pawel's mail, but it sounded like he
>> would have expected an eponymous find_get_pages() lockup by now,
>> and was pleased that this patch appeared to have cured that.
>>
>> I've spent quite a while trying to explain find_get_pages() lockup by
>> a missed migration entry, but I just don't see it: I don't expect this
>> (or the alternative) patch to do anything to fix that problem. =C2=A0I w=
on't
>> mind if it magically goes away, but I expect we'll need more info from
>> the debug patch I sent Justin a couple of days ago.
>
> the latest patch (mm/migrate.c) applied on 3.0.4 also survives points
> 1) and 2) described previously (https://lkml.org/lkml/2011/10/18/427),
> so please apply it to the upstream/stable git tree.
>
> from the other side, both patches don't help for 3.0.4+vserver host soft-=
lock

Hi Pawe=C5=82,

Did your "both" mean that you applied each patch and run the tests separate=
ly,
or you applied the both patches and run them together?

Maybe there were more than one bugs dancing but having a same effect,
not fixing all of them wouldn't help at all.

Thanks,

Nai Xia


> which dies in few hours of stressing. iirc this lock has started with 2.6=
.38.
> is there any major change in memory managment area in 2.6.38 that i can b=
isect
> and test with vserver?
>
> BR,
> Pawe=C5=82.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
