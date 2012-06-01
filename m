Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 3856C6B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 08:22:55 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3676490pbb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 05:22:54 -0700 (PDT)
Date: Fri, 1 Jun 2012 05:21:18 -0700
From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH 0/5] Some vmevent fixes...
Message-ID: <20120601122118.GA6128@lizard>
References: <20120504073810.GA25175@lizard>
 <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
 <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
 <20120507121527.GA19526@lizard>
 <4FA82056.2070706@gmail.com>
 <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
 <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
 <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
 <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
 <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 08, 2012 at 10:36:31AM +0300, Pekka Enberg wrote:
[...]
> > 2) VMEVENT_ATTR_STATE_ONE_SHOT is misleading name. That is effect as
> > edge trigger shot. not only once.
> 
> Would VMEVENT_ATTR_STATE_EDGE_TRIGGER be a better name?
[...] 
> > 4) Currently, vmstat have per-cpu batch and vmstat updating makes 3
> > second delay at maximum.
> > A This is fine for usual case because almost userland watcher only
> > read /proc/vmstat per second.
> > A But, for vmevent_fd() case, 3 seconds may be unacceptable delay. At
> > worst, 128 batch x 4096
> > A x 4k pagesize = 2G bytes inaccurate is there.
> 
> That's pretty awful. Anton, Leonid, comments?
[...]
> > 5) __VMEVENT_ATTR_STATE_VALUE_WAS_LT should be removed from userland
> > exporting files.
> > A When exporing kenrel internal, always silly gus used them and made unhappy.
> 
> Agreed. Anton, care to cook up a patch to do that?

KOSAKI-San, Pekka,

Much thanks for your reviews!

These three issues should be fixed by the following patches. One mm/
change is needed outside of vmevent...

And I'm looking into other issues you pointed out...

Thanks!

---
 include/linux/vmevent.h |   10 +++----
 include/linux/vmstat.h  |    2 ++
 mm/vmevent.c            |   66 +++++++++++++++++++++++++++++------------------
 mm/vmstat.c             |   22 +++++++++++++++-
 4 files changed, 68 insertions(+), 32 deletions(-)

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
