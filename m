Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0CF6B02A0
	for <linux-mm@kvack.org>; Sun, 30 Oct 2016 00:17:28 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ml10so68395008pab.5
        for <linux-mm@kvack.org>; Sat, 29 Oct 2016 21:17:28 -0700 (PDT)
Received: from peace.netnation.com (peace.netnation.com. [204.174.223.2])
        by mx.google.com with ESMTPS id ps1si16189357pac.10.2016.10.29.21.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 29 Oct 2016 21:17:27 -0700 (PDT)
Date: Sat, 29 Oct 2016 21:17:23 -0700
From: Simon Kirby <sim@hostway.ca>
Subject: Re: More OOM problems
Message-ID: <20161030041723.GA4767@hostway.ca>
References: <eafb59b5-0a2b-0e28-ca79-f044470a2851@Quantum.com>
 <20160930214448.GB28379@dhcp22.suse.cz>
 <982671bd-5733-0cd5-c15d-112648ff14c5@Quantum.com>
 <20161011064426.GA31996@dhcp22.suse.cz>
 <c71036ae-73db-f05a-fd14-fe2de44515b9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c71036ae-73db-f05a-fd14-fe2de44515b9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Tue, Oct 11, 2016 at 09:10:13AM +0200, Vlastimil Babka wrote:

> Great indeed. Note that meanwhile the patches went to mainline so
> we'd definitely welcome testing from the rest of you who had
> originally problems with 4.7/4.8 and didn't try the linux-next
> recently. So a good point would be to test 4.9-rc1 when it's
> released. I hope you don't want to discover regressions again too
> late, in the 4.9 final release :)

Hello!

I have a mixed-purpose HTPCish box running MythTV, etc. that I recently
upgraded from 4.6.7 to 4.8.4. This upgrade started OOM killing of various
processes even when there is plenty (gigabytes) of memory as page cache.

This is with CONFIG_COMPACTION=y, and it occurs with or without swap on.
I'm not able to confirm on 4.9-rc2 since nouveau doesn't support NV117
and binary blob nvidia doesn't yet like the changes to get_user_pages.

4.8 includes "prevent premature OOM killer invocation for high order
request" which sounds like it should fix the issue, but this certainly
does not seem to be the case for me. I copied kern.log and .config here:
http://0x.ca/sim/ref/4.8.4/

I see that this is reverted in 4.9-rc and replaced with something else.
Unfortunately, I can't test this workload without the nvidia tainting,
and "git log --oneline v4.8..v4.9-rc2 mm | grep oom | wc -l" returns 13.
Is there some stuff I should cherry-pick to try?

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
