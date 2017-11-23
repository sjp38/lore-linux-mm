Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 176D06B0261
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:02:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s18so18591445pge.19
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:02:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e29si15326993pgn.215.2017.11.23.02.02.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 02:02:20 -0800 (PST)
Date: Thu, 23 Nov 2017 11:02:18 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Message-ID: <20171123100218.vf4zc47pmy3f67ey@dhcp22.suse.cz>
References: <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
 <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
 <20171122203907.GI4094@dastard>
 <201711231534.BBI34381.tJOOHLQMOFVFSF@I-love.SAKURA.ne.jp>
 <2178e42e-9600-4f9a-4b91-22d2ba6f98c0@redhat.com>
 <201711231856.CFH69777.FtOSJFMQHLOVFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711231856.CFH69777.FtOSJFMQHLOVFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: pbonzini@redhat.com, david@fromorbit.com, akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On Thu 23-11-17 18:56:53, Tetsuo Handa wrote:
> Paolo Bonzini wrote:
> > On 23/11/2017 07:34, Tetsuo Handa wrote:
> > >> Just fix the numa aware shrinkers, as they are the only ones that
> > >> will have this problem. There are only 6 of them, and only the 3
> > >> that existed at the time that register_shrinker() was changed to
> > >> return an error fail to check for an error. i.e. the superblock
> > >> shrinker, the XFS dquot shrinker and the XFS buffer cache shrinker.
> > >
> > > You are assuming the "too small to fail" memory-allocation rule
> > > by ignoring that this problem is caused by fault injection.
> > 
> > Fault injection should also obey the too small to fail rule, at least by
> > default.
> > 
> 
> Pardon? Most allocation requests in the kernel are <= 32KB.
> Such change makes fault injection useless. ;-)

Agreed! All we need is to fix the shrinker registration callers. It is
that simple. The rest is just a distraction.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
