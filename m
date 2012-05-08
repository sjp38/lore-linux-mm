Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id D62ED6B0081
	for <linux-mm@kvack.org>; Tue,  8 May 2012 01:53:57 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so12697738obb.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 22:53:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
References: <20120501132409.GA22894@lizard>
	<20120501132620.GC24226@lizard>
	<4FA35A85.4070804@kernel.org>
	<20120504073810.GA25175@lizard>
	<CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
	<CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
	<20120507121527.GA19526@lizard>
	<4FA82056.2070706@gmail.com>
	<CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
	<CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
Date: Tue, 8 May 2012 08:53:56 +0300
Message-ID: <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 8, 2012 at 8:42 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>> That said, I think you are being unfair to Anton who's one of the few
>> that's actually taking the time to implement this properly instead of
>> settling for an out-of-tree hack.
>
> Unfair? But only I can talk about technical comment. To be honest, I
> really dislike
> I need say the same explanation again and again. A lot of people don't read
> past discussion. And as far as the patches take the same mistake, I must say
> the same thing. It is just PITA.

Unfair because you are trying to make it look as if Anton is only
concerned with his specific use case. That's simply not true.

On Tue, May 8, 2012 at 8:42 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> I don't disagree vmevent notification itself, but I must disagree lie
> notification.
> And also, To make just idea statistics doesn't make sense at all. How do an
> application choose the right events? If that depend on hardware configuration,
> userland developers can't write proper applications.

That's exactly the problem we're trying to tackle here! We _want_ the
ABI to provide sane, well-defined events that solve real world
problems.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
