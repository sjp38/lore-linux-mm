Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3AA28026C
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 17:48:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so64581009wmf.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:48:28 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id ej4si16778364wjb.56.2016.09.25.14.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 14:48:27 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id l132so120486577wmf.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:48:26 -0700 (PDT)
Date: Sun, 25 Sep 2016 22:48:23 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: More OOM problems
Message-ID: <20160925214823.GA9321@lucifer>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160918202614.GB31286@lucifer>
 <20160919083215.GF10785@dhcp22.suse.cz>
 <20160919084237.GA30625@lucifer>
 <20160919085348.GG10785@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919085348.GG10785@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon, Sep 19, 2016 at 10:53:48AM +0200, Michal Hocko wrote:
> On Mon 19-09-16 09:42:37, Lorenzo Stoakes wrote:
> > On Mon, Sep 19, 2016 at 10:32:15AM +0200, Michal Hocko wrote:
> > >
> > > so this is the same thing as in Linus case. All the zones are hitting
> > > min wmark so the should_compact_retry() gave up. As mentioned in other
> > > email [1] this is inherent limitation of the workaround. Your system is
> > > swapless but there is a lot of the reclaimable page cache so Vlastimil's
> > > patches should help.
> >
> > I will experiment with a linux-next kernel and see if the problem
> > recurs. I've attempted to see if there is a way to manually reproduce
> > on the mainline kernel by performing workloads that triggered the
> > OOM (loading google sheets tabs, compiling a kernel, playing a video
> > on youtube), but to no avail - it seems the system needs to be
> > sufficiently fragmented first before it'll trigger.
> >
> > Given that's the case, I'll just have to try using the linux-next
> > kernel and if you don't hear from me you can assume it did not repro
> > again :)
>
> OK, fair deal ;)

Actually, I'll break the deal :) I've been running workloads similar to previous
weeks when I encountered the issue - including kernel builds, video playing,
lotsa tabs, etc. and also tried to intentionally eat up a bit of RAM from
time-to-time and have not seen a single OOM, so it looks like this is sorted it
for my system, notwithstanding Murphy's law.

(I ended up using the mm tree as irritatingly I couldn't get linux-next working
with the arch linux build system, but it definitely includes Vlastimil's
patches.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
