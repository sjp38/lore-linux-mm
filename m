Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB9296B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 21:45:06 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id c41-v6so4572695plj.10
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 18:45:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e2si1679474pgq.596.2018.03.09.18.45.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Mar 2018 18:45:04 -0800 (PST)
Subject: Re: Removing GFP_NOFS
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180308234618.GE29073@bombadil.infradead.org>
	<20180309013535.GU7000@dastard>
	<20180309040650.GV7000@dastard>
	<e461128e-6724-3c7f-0f62-860ac4071357@suse.de>
	<20180309223812.GW7000@dastard>
In-Reply-To: <20180309223812.GW7000@dastard>
Message-Id: <201803101144.IHI87002.MFOtLJOFQVHSFO@I-love.SAKURA.ne.jp>
Date: Sat, 10 Mar 2018 11:44:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, rgoldwyn@suse.de, mhocko@kernel.org
Cc: willy@infradead.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Dave Chinner wrote:
> > OTOH (contradicting myself here), writepages, in essence writebacks, are
> > performed by per-BDI flusher threads which are kicked by the mm code in
> > low memory situations, as opposed to the thread performing the allocation.
> > 
> > As Tetsuo pointed out, direct reclaims are the real problematic scenarios.
> 
> Sure, but I've been saying for more than 10 years we need to get rid
> of direct reclaim because it's horribly inefficient when there's
> lots of concurrent allocation pressure, not to mention it's full of
> deadlock scenarios like this.
> 
> Really, though I'm tired of having the same arguments over and over
> again about architectural problems that people just don't seem to
> understand or want to fix.
> 
Yeah, it is sad that developers are not interested in lowmem situation.

  Suspect the MM subsystem when your Linux system hung up!?
  https://elinux.org/images/4/49/CELFJP-Jamboree63-handa-en.pdf
