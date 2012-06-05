Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 41C916B0072
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 04:41:02 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9129395pbb.14
        for <linux-mm@kvack.org>; Tue, 05 Jun 2012 01:41:01 -0700 (PDT)
Date: Tue, 5 Jun 2012 01:39:22 -0700
From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
Message-ID: <20120605083921.GA21745@lizard>
References: <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
 <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
 <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
 <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
 <20120601122118.GA6128@lizard>
 <alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
 <4FCC7592.9030403@kernel.org>
 <20120604113811.GA4291@lizard>
 <4FCD14F1.1030105@gmail.com>
 <CAOJsxLHR4wSgT2hNfOB=X6ud0rXgYg+h7PTHzAZYCUdLs6Ktug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOJsxLHR4wSgT2hNfOB=X6ud0rXgYg+h7PTHzAZYCUdLs6Ktug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, Jun 05, 2012 at 10:47:18AM +0300, Pekka Enberg wrote:
> On Mon, Jun 4, 2012 at 11:05 PM, KOSAKI Motohiro
> <kosaki.motohiro@gmail.com> wrote:
> >> Note that 1) and 2) are not problems per se, it's just implementation
> >> details, easy stuff. Vmevent is basically an ABI/API, and I didn't
> >> hear anybody who would object to vmevent ABI idea itself. More than
> >> this, nobody stop us from implementing in-kernel vmevent API, and
> >> make Android Lowmemory killer use it, if we want to.
> >
> > I never agree "it's mere ABI" discussion. Until the implementation is ugly,
> > I never agree the ABI even if syscall interface is very clean.
> 
> I don't know what discussion you are talking about.
> 
> I also don't agree that something should be merged just because the
> ABI is clean. The implementation must also make sense. I don't see how
> we disagree here at all.

BTW, I wasn't implying that vmevent should be merged just because
it is a clean ABI, and I wasn't implying that it is clean, and I
didn't propose to merge it at all. :-)

I just don't see any point in trying to scrap vmevent in favour of
Android low memory killer. This makes no sense at all, since today
vmevent is more useful than Android's solution. For vmevent we have
contributors from Nokia, Samsung, and of course Linaro, plus we
have an userland killer daemon* for Android (which can work with
both cgroups and vmevent backends). So vmevent is more generic
already.

To me it would make more sense if mm guys would tell us "scrap
this all, just use cgroups and its notifications; fix cgroups'
slab accounting and be happy". Well, I'd understand that.

Anyway, we all know that vmevent is 'work in progress', so nobody
tries to push it, nobody asks to merge it. So far we're just
discussing any possible solutions, and vmevent is a good
playground.


So, question to Minchan. Do you have anything particular in mind
regarding how the vmstat hooks should look like? And how all this
would connect with cgroups, since KOSAKI wants to see it cgroups-
aware...

p.s. http://git.infradead.org/users/cbou/ulmkd.git
     I haven't updated it for new vmevent changes, but still,
     its idea should be clear enough.

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
