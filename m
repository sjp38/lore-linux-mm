Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D803F6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 04:53:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l132so56954430wmf.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 01:53:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5si17311793wmc.122.2016.09.19.01.53.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 01:53:50 -0700 (PDT)
Date: Mon, 19 Sep 2016 10:53:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160919085348.GG10785@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160918202614.GB31286@lucifer>
 <20160919083215.GF10785@dhcp22.suse.cz>
 <20160919084237.GA30625@lucifer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919084237.GA30625@lucifer>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon 19-09-16 09:42:37, Lorenzo Stoakes wrote:
> On Mon, Sep 19, 2016 at 10:32:15AM +0200, Michal Hocko wrote:
> >
> > so this is the same thing as in Linus case. All the zones are hitting
> > min wmark so the should_compact_retry() gave up. As mentioned in other
> > email [1] this is inherent limitation of the workaround. Your system is
> > swapless but there is a lot of the reclaimable page cache so Vlastimil's
> > patches should help.
> 
> I will experiment with a linux-next kernel and see if the problem
> recurs. I've attempted to see if there is a way to manually reproduce
> on the mainline kernel by performing workloads that triggered the
> OOM (loading google sheets tabs, compiling a kernel, playing a video
> on youtube), but to no avail - it seems the system needs to be
> sufficiently fragmented first before it'll trigger.
>
> Given that's the case, I'll just have to try using the linux-next
> kernel and if you don't hear from me you can assume it did not repro
> again :)

OK, fair deal ;)

> I actually have a whole bunch of other OOM kill logs that I saved
> from previous occurrences of this issue, would it be useful for me to
> pastebin them, or would they not add anything of use beyond what's
> been shown in this thread?

If they are from before the workaround then it probably won't be that
useful.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
