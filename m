Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 31D976B004D
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 14:27:04 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3567909lbj.14
        for <linux-mm@kvack.org>; Sun, 03 Jun 2012 11:27:02 -0700 (PDT)
Date: Sun, 3 Jun 2012 21:26:50 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
In-Reply-To: <20120601122118.GA6128@lizard>
Message-ID: <alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
References: <20120504073810.GA25175@lizard> <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com> <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com> <20120507121527.GA19526@lizard> <4FA82056.2070706@gmail.com>
 <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com> <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com> <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com> <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
 <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com> <20120601122118.GA6128@lizard>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1426780772-1338748020=:1943"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <cbouatmailru@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1426780772-1338748020=:1943
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Fri, 1 Jun 2012, Anton Vorontsov wrote:
> > That's pretty awful. Anton, Leonid, comments?
> [...]
> > > 5) __VMEVENT_ATTR_STATE_VALUE_WAS_LT should be removed from userland
> > > exporting files.
> > > A When exporing kenrel internal, always silly gus used them and made unhappy.
> > 
> > Agreed. Anton, care to cook up a patch to do that?
> 
> KOSAKI-San, Pekka,
> 
> Much thanks for your reviews!
> 
> These three issues should be fixed by the following patches. One mm/
> change is needed outside of vmevent...
> 
> And I'm looking into other issues you pointed out...

I applied patches 2, 4, and 5. The vmstat patch need ACKs from VM folks 
to enter the tree.

			Pekka
--8323328-1426780772-1338748020=:1943--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
