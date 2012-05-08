Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 5945C6B004D
	for <linux-mm@kvack.org>; Tue,  8 May 2012 01:20:25 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so12634305obb.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 22:20:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA82056.2070706@gmail.com>
References: <20120501132409.GA22894@lizard>
	<20120501132620.GC24226@lizard>
	<4FA35A85.4070804@kernel.org>
	<20120504073810.GA25175@lizard>
	<CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
	<CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
	<20120507121527.GA19526@lizard>
	<4FA82056.2070706@gmail.com>
Date: Tue, 8 May 2012 08:20:24 +0300
Message-ID: <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, May 7, 2012 at 10:19 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>> Even more, we may introduce two attributes:
>>
>> RECLAIMABLE_CACHE_PAGES and
>> RECLAIMABLE_CACHE_PAGES_NOIO (which excludes dirty pages).
>>
>> This makes ABI detached from the mm internals and still keeps a
>> defined meaning of the attributes.
>
> Collection of craps are also crap. If you want to improve userland
> notification, you should join VM improvement activity. You shouldn't
> think nobody except you haven't think userland notification feature.
>
> The problem is, Any current kernel vm statistics were not created for
> such purpose and don't fit.
>
> Even though, some inaccurate and incorrect statistics fit _your_ usecase,
> they definitely don't fit other. And their people think it is bug.

Well, yeah, if we are to report _number of pages_, the numbers better
be meaningful.

That said, I think you are being unfair to Anton who's one of the few
that's actually taking the time to implement this properly instead of
settling for an out-of-tree hack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
