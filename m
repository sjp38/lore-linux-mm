Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 038176B0274
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 09:54:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so12954222wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:54:05 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id rw19si30087524wjb.184.2016.04.26.06.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 06:54:04 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n3so5272946wmn.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:54:04 -0700 (PDT)
Date: Tue, 26 Apr 2016 15:54:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
Message-ID: <20160426135402.GB20813@dhcp22.suse.cz>
References: <20160419200752.GA10437@dhcp22.suse.cz>
 <201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
 <20160420144758.GA7950@dhcp22.suse.cz>
 <201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
 <20160421130750.GA18427@dhcp22.suse.cz>
 <201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
 <20160425095508.GE23933@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160425095508.GE23933@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Mon 25-04-16 11:55:08, Michal Hocko wrote:
> On Sun 24-04-16 23:19:03, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > I have seen that patch. I didn't get to review it properly yet as I am
> > > still travelling. From a quick view I think it is conflating two things
> > > together. I could see arguments for the panic part but I do not consider
> > > the move-to-kill-another timeout as justified. I would have to see a
> > > clear indication this is actually useful for real life usecases.
> > 
> > You admit that it is possible that the TIF_MEMDIE thread is blocked at
> > unkillable wait (due to memory allocation requests by somebody else) but
> > the OOM reaper cannot reap the victim's memory (due to holding the mmap_sem
> > for write), don't you?
> 
> I have never said this to be impossible.

And just to clarify. I consider unkillable sleep while holding mmap_sem
for write to be a _bug_ which should be fixed rather than worked around
by some timeout based heuristics.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
