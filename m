Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 730916B026A
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:40:05 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id t47so10016757otd.19
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 02:40:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s129si7456632oie.309.2017.11.23.02.40.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 02:40:04 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171122203907.GI4094@dastard>
	<201711231534.BBI34381.tJOOHLQMOFVFSF@I-love.SAKURA.ne.jp>
	<2178e42e-9600-4f9a-4b91-22d2ba6f98c0@redhat.com>
	<201711231856.CFH69777.FtOSJFMQHLOVFO@I-love.SAKURA.ne.jp>
	<20171123100218.vf4zc47pmy3f67ey@dhcp22.suse.cz>
In-Reply-To: <20171123100218.vf4zc47pmy3f67ey@dhcp22.suse.cz>
Message-Id: <201711231938.EDI78635.FVOOSHOFtJFMLQ@I-love.SAKURA.ne.jp>
Date: Thu, 23 Nov 2017 19:38:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: pbonzini@redhat.com, david@fromorbit.com, akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com, sfr@canb.auug.org.au

Michal Hocko wrote:
> On Thu 23-11-17 18:56:53, Tetsuo Handa wrote:
> > Paolo Bonzini wrote:
> > > On 23/11/2017 07:34, Tetsuo Handa wrote:
> > > >> Just fix the numa aware shrinkers, as they are the only ones that
> > > >> will have this problem. There are only 6 of them, and only the 3
> > > >> that existed at the time that register_shrinker() was changed to
> > > >> return an error fail to check for an error. i.e. the superblock
> > > >> shrinker, the XFS dquot shrinker and the XFS buffer cache shrinker.
> > > >
> > > > You are assuming the "too small to fail" memory-allocation rule
> > > > by ignoring that this problem is caused by fault injection.
> > > 
> > > Fault injection should also obey the too small to fail rule, at least by
> > > default.
> > > 
> > 
> > Pardon? Most allocation requests in the kernel are <= 32KB.
> > Such change makes fault injection useless. ;-)
> 
> Agreed! All we need is to fix the shrinker registration callers. It is
> that simple. The rest is just a distraction.
> 

Which coverage (all register_shrinker() callers or only SHRINKER_NUMA_AWARE
callers) are you talking about? If the former, keeping __must_check is OK.
If the latter, it will not avoid future oops reports with fault injection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
