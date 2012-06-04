Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E2E676B005D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 18:41:30 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8235739dak.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 15:41:30 -0700 (PDT)
Date: Mon, 4 Jun 2012 15:39:51 -0700
From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
Message-ID: <20120604223951.GA20591@lizard>
References: <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
 <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
 <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
 <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
 <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
 <20120601122118.GA6128@lizard>
 <alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
 <4FCC7592.9030403@kernel.org>
 <20120604113811.GA4291@lizard>
 <4FCD14F1.1030105@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FCD14F1.1030105@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Jun 04, 2012 at 04:05:05PM -0400, KOSAKI Motohiro wrote:
[...]
> >Yes, nobody throws Android lowmemory killer away. And recently I fixed
> >a bunch of issues in its tasks traversing and killing code. Now it's
> >just time to "fix" statistics gathering and interpretation issues,
> >and I see vmevent as a good way to do just that, and then we
> >can either turn Android lowmemory killer driver to use the vmevent
> >in-kernel API (so it will become just a "glue" between notifications
> >and killing functions), or use userland daemon.
> 
> Huh? No? android lowmem killer is a "killer". it doesn't make any notification,
> it only kill memory hogging process. I don't think we can merge them.

KOSAKI, you don't read what I write. I didn't ever say that low memory
killer makes any notifications, that's not what I was saying. I said
that once we'll have a good "low memory" notification mechanism (e.g.
vmevent), Android low memory killer would just use this mechanism. Be
it userland notifications or in-kernel, doesn't matter much.

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
