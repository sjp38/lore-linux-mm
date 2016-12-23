Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61BE2280268
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 07:18:57 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so40835545wmu.1
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 04:18:57 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id g66si31824336wmf.113.2016.12.23.04.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 04:18:55 -0800 (PST)
Date: Fri, 23 Dec 2016 13:18:51 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161223121851.GA27413@ppc-nas.fritz.box>
References: <20161217125950.GA3321@boerne.fritz.box>
 <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161223105157.GB23109@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri, Dec 23, 2016 at 11:51:57AM +0100, Michal Hocko wrote:
> TL;DR
> drop the last patch, check whether memory cgroup is enabled and retest
> with cgroup_disable=memory to see whether this is memcg related and if
> it is _not_ then try to test with the patch below

Right, it seems we might be looking in the right direction! So I
removed the previous patch from my kernel and verified if memory
cgroup was enabled, and indeed, it was. So I booted with
cgroup_disable=memory and ran my ordinary test again ... and in fact,
no ooms! I could have the firefox sources building and unpack half a
dozen big tarballs, which would previously with 99% certainty already
trigger an OOM upon unpacking the first tarball. Also, the system
seemed to run noticably "nicer", in the sense that the other processes
I had running (like htop) would not get delayed / hung. The new patch
you sent has, as per your instructions, NOT been applied.

I've provided a log of this run, it's available at:

http://ftp.tisys.org/pub/misc/boerne_2016-12-23.log.xz

As no OOMs or other bad situations occured, no memory information was
forcibly logged. However, about three times I triggered a memory info
manually via SysReq, because I guess that might be interesting for you
to look at.

I'd like to run the same test on my second machine as well just to
make sure that cgroup_disable=memory has an effect there too. I
should be able to do that later tonight and will report back as soon
as I know more!

> I would appreciate to stick with your setup to not pull new unknows into
> the picture.

No problem! It's just likely that I won't be able to test during the
following days until Dec 27th, but after that I should be back to
normal and thus be able to run further tests in a timely fashion. :-)

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
