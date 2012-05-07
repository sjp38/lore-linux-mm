Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 1AF686B0083
	for <linux-mm@kvack.org>; Mon,  7 May 2012 04:26:22 -0400 (EDT)
Received: by ghbf11 with SMTP id f11so277142ghb.8
        for <linux-mm@kvack.org>; Mon, 07 May 2012 01:26:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
References: <20120501132409.GA22894@lizard> <20120501132620.GC24226@lizard>
 <4FA35A85.4070804@kernel.org> <20120504073810.GA25175@lizard> <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 7 May 2012 04:26:00 -0400
Message-ID: <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

>> If we'll give up on "1." (Pekka, ping), then we need to solve "2."
>> in a sane way: we'll have to add a 'NR_FILE_PAGES - NR_SHMEM -
>> <todo-locked-file-pages>' attribute, and give it a name.
>
> Well, no, we can't give up on (1) completely. That'd mean that
> eventually we'd need to change the ABI and break userspace. The
> difference between exposing internal details and reasonable
> abstractions is by no means black and white.
>
> AFAICT, RECLAIMABLE_CACHE_PAGES is a reasonable thing to support. Can
> anyone come up with a reason why we couldn't do that in the future?

It can. but the problem is, that is completely useless. Because of, 1)
dirty pages writing-out
is sometimes very slow and 2) libc and some important library's pages
are critical important
for running a system even though it is clean and reclaimable. In other
word, kernel don't have
an info then can't expose it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
