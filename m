Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD48280266
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 03:48:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l132so74137676wmf.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 00:48:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g79si7404935wmi.123.2016.09.26.00.48.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 00:48:08 -0700 (PDT)
Date: Mon, 26 Sep 2016 09:48:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160926074807.GA27030@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160918202614.GB31286@lucifer>
 <20160919083215.GF10785@dhcp22.suse.cz>
 <20160919084237.GA30625@lucifer>
 <20160919085348.GG10785@dhcp22.suse.cz>
 <20160925214823.GA9321@lucifer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160925214823.GA9321@lucifer>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun 25-09-16 22:48:23, Lorenzo Stoakes wrote:
> On Mon, Sep 19, 2016 at 10:53:48AM +0200, Michal Hocko wrote:
> > On Mon 19-09-16 09:42:37, Lorenzo Stoakes wrote:
> > > On Mon, Sep 19, 2016 at 10:32:15AM +0200, Michal Hocko wrote:
> > > >
> > > > so this is the same thing as in Linus case. All the zones are hitting
> > > > min wmark so the should_compact_retry() gave up. As mentioned in other
> > > > email [1] this is inherent limitation of the workaround. Your system is
> > > > swapless but there is a lot of the reclaimable page cache so Vlastimil's
> > > > patches should help.
> > >
> > > I will experiment with a linux-next kernel and see if the problem
> > > recurs. I've attempted to see if there is a way to manually reproduce
> > > on the mainline kernel by performing workloads that triggered the
> > > OOM (loading google sheets tabs, compiling a kernel, playing a video
> > > on youtube), but to no avail - it seems the system needs to be
> > > sufficiently fragmented first before it'll trigger.
> > >
> > > Given that's the case, I'll just have to try using the linux-next
> > > kernel and if you don't hear from me you can assume it did not repro
> > > again :)
> >
> > OK, fair deal ;)
> 
> Actually, I'll break the deal :) I've been running workloads similar to previous
> weeks when I encountered the issue - including kernel builds, video playing,
> lotsa tabs, etc. and also tried to intentionally eat up a bit of RAM from
> time-to-time and have not seen a single OOM, so it looks like this is sorted it
> for my system, notwithstanding Murphy's law.

Thanks for the feedback. Your testing is highly appreciated! I guess
Andrew can put your Tested-by for the latest Vlastimil patches to credit
your effort.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
