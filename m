Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DDBD36B00F4
	for <linux-mm@kvack.org>; Tue,  8 May 2012 03:17:02 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so4827582qcs.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 00:17:01 -0700 (PDT)
Message-ID: <4FA8C86B.8010205@gmail.com>
Date: Tue, 08 May 2012 03:16:59 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
References: <20120501132409.GA22894@lizard> <20120501132620.GC24226@lizard> <4FA35A85.4070804@kernel.org> <20120504073810.GA25175@lizard> <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com> <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com> <20120507121527.GA19526@lizard> <4FA82056.2070706@gmail.com> <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com> <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com> <20120508065829.GA13357@lizard>
In-Reply-To: <20120508065829.GA13357@lizard>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(5/8/12 2:58 AM), Anton Vorontsov wrote:
> On Tue, May 08, 2012 at 01:42:05AM -0400, KOSAKI Motohiro wrote:
> [...]
>>> Well, yeah, if we are to report _number of pages_, the numbers better
>>> be meaningful.
>>>
>>> That said, I think you are being unfair to Anton who's one of the few
>>> that's actually taking the time to implement this properly instead of
>>> settling for an out-of-tree hack.
>>
>> Unfair? But only I can talk about technical comment. To be honest, I
>> really dislike
>> I need say the same explanation again and again. A lot of people don't read
>> past discussion. And as far as the patches take the same mistake, I must say
>> the same thing. It is just PITA.
>
> Note that just telling people that something is PITA doesn't help solve
> things (so people will come back to you with stupid questions over and
> over again). You can call people morons, idiots and dumbasses (that's
> all fine) but still finding a way to be productive. :-)
>
> You could just give a link to a previous discussion, in which you think
> you explained all your concerns regarding cache handling issues, or
> memory notifications/statistics in general.
>
> So, feel free to call me an idiot, but please expand your points a
> little bit or give a link to the discussion you're referring to?

I don't think you are idiot. But I hope you test your patch before submitting.
That just don't work especially on x86. Because of, all x86 box have multiple zone
and summarized statistics (i.e. global_page_state() thing) don't work and can't
prevent oom nor swapping.

and please see may previous mail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
