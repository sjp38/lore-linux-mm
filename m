Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 255CC6B0080
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 18:08:46 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id rd3so10561883pab.11
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 15:08:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id wm7si12015614pab.69.2014.04.01.15.08.44
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 15:08:45 -0700 (PDT)
Date: Tue, 1 Apr 2014 15:08:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Message-Id: <20140401150843.13da3743554ad541629c936d@linux-foundation.org>
In-Reply-To: <1396389751.25314.26.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	<20140331170546.3b3e72f0.akpm@linux-foundation.org>
	<1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
	<CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
	<1396377083.25314.17.camel@buesod1.americas.hpqcorp.net>
	<CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
	<1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
	<CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
	<20140401142947.927642a408d84df27d581e36@linux-foundation.org>
	<CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
	<20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
	<1396389751.25314.26.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 01 Apr 2014 15:02:31 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Tue, 2014-04-01 at 14:48 -0700, Andrew Morton wrote:
> > On Tue, 1 Apr 2014 17:41:54 -0400 KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:
> > 
> > > >> > Hmmm so 0 won't really work because it could be weirdly used to disable
> > > >> > shm altogether... we cannot go to some negative value either since we're
> > > >> > dealing with unsigned, and cutting the range in half could also hurt
> > > >> > users that set the limit above that. So I was thinking of simply setting
> > > >> > SHMMAX to ULONG_MAX and be done with it. Users can then set it manually
> > > >> > if they want a smaller value.
> > > >> >
> > > >> > Makes sense?
> > > >>
> > > >> I don't think people use 0 for disabling. but ULONG_MAX make sense to me too.
> > > >
> > > > Distros could have set it to [U]LONG_MAX in initscripts ten years ago
> > > > - less phone calls, happier customers.  And they could do so today.
> > > >
> > > > But they haven't.   What are the risks of doing this?
> > > 
> > > I have no idea really. But at least I'm sure current default is much worse.
> > > 
> > > 1. Solaris changed the default to total-memory/4 since Solaris 10 for DB.
> > >  http://www.postgresql.org/docs/9.1/static/kernel-resources.html
> > > 
> > > 2. RHEL changed the default to very big size since RHEL5 (now it is
> > > 64GB). Even tough many box don't have 64GB memory at that time.
> > 
> > Ah-hah, that's interesting info.
> > 
> > Let's make the default 64GB?
> 
> But again, yet another arbitrary value...

Well, I'm assuming 64GB==infinity.  It *was* infinity in the RHEL5
timeframe, but infinity has since become larger so pickanumber.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
