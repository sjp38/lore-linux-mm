Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 95DC26B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 03:35:03 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5648228iaj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 00:35:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F9E39F1.5030600@kernel.org>
References: <4F9E39F1.5030600@kernel.org>
Date: Mon, 30 Apr 2012 10:35:02 +0300
Message-ID: <CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com>
Subject: Re: vmevent: question?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

Hi Minchan,

On Mon, Apr 30, 2012 at 10:06 AM, Minchan Kim <minchan@kernel.org> wrote:
> vmevent_smaple gathers all registered values to report to user if vmevent=
 match.
> But the time gap between vmevent match check and vmevent_sample_attr coul=
d make error
> so user could confuse.
>
> Q 1. Why do we report _all_ registered vmstat value?
> =A0 =A0 In my opinion, it's okay just to report _a_ value vmevent_match h=
appens.

It makes the userspace side simpler for "lowmem notification" use
case. I'm open to changing the ABI if it doesn't make the userspace
side too complex.

> Q 2. Is it okay although value when vmevent_match check happens is differ=
ent with
> =A0 =A0 vmevent_sample_attr in vmevent_sample's for loop?
> =A0 =A0 I think it's not good.

Yeah, that's just silly and needs fixing.

> Q 3. Do you have any plan to change getting value's method?
> =A0 =A0 Now it's IRQ context so we have limitation to get a vmstat values=
 so that
> =A0 =A0 It couldn't be generic. IMHO, To merge into mainline, we should s=
olve this problem.

Yes, that needs fixing as well. I was hoping to reuse perf sampling
code for this.

> Q 4. Do you have any plan for this patchset to merge into mainline?

Yes, I'm interested in pushing it forward if we can show that the ABI
makes sense, is stable and generic enough, and fixes real world
problems.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
