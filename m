Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DB26E6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 05:36:49 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id x188so10168349pfb.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 02:36:49 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id bp6si3910900pac.135.2016.03.08.02.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 02:36:49 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id fl4so10020007pad.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 02:36:48 -0800 (PST)
Date: Tue, 8 Mar 2016 02:36:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was:
 Re: [PATCH 0/3] OOM detection rework v4)
In-Reply-To: <20160307160838.GB5028@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1603080214270.7589@eggly.anvils>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz> <alpine.LSU.2.11.1602241832160.15564@eggly.anvils> <20160225092315.GD17573@dhcp22.suse.cz> <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-833420703-1457433407=:7589"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-833420703-1457433407=:7589
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Mon, 7 Mar 2016, Michal Hocko wrote:
> On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> > Andrew,
> > could you queue this one as well, please? This is more a band aid than a
> > real solution which I will be working on as soon as I am able to
> > reproduce the issue but the patch should help to some degree at least.
> 
> Joonsoo wasn't very happy about this approach so let me try a different
> way. What do you think about the following? Hugh, Sergey does it help
> for your load? I have tested it with the Hugh's load and there was no
> major difference from the previous testing so at least nothing has blown
> up as I am not able to reproduce the issue here.

Did not help with my load at all, I'm afraid: quite the reverse,
OOMed very much sooner (as usual on order=2), and with much more
noise (multiple OOMs) than your previous patch.

vmstats.xz attached; sorry, I don't have tracing built in,
and must move on to the powerpc issue before going back to bed.

I do hate replying without having something constructive to say, but
have very little time to think about this, and no bright ideas so far.

I do not understand why it's so easy for me to reproduce, yet impossible
for you - unless it's that you are still doing all your testing in a VM?
Is Sergey the only other to see this issue?

Hugh
--0-833420703-1457433407=:7589
Content-Type: APPLICATION/x-xz; name=vmstats.xz
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.LSU.2.11.1603080236390.7589@eggly.anvils>
Content-Description: 
Content-Disposition: attachment; filename=vmstats.xz

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
Z/sCAAAAAARZWg==

--0-833420703-1457433407=:7589--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
