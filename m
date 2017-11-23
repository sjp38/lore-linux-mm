Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 899B26B025E
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:58:54 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f28so9855409otd.12
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:58:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t7si7462532oit.346.2017.11.23.01.58.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 01:58:53 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
	<201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
	<20171122203907.GI4094@dastard>
	<201711231534.BBI34381.tJOOHLQMOFVFSF@I-love.SAKURA.ne.jp>
	<2178e42e-9600-4f9a-4b91-22d2ba6f98c0@redhat.com>
In-Reply-To: <2178e42e-9600-4f9a-4b91-22d2ba6f98c0@redhat.com>
Message-Id: <201711231856.CFH69777.FtOSJFMQHLOVFO@I-love.SAKURA.ne.jp>
Date: Thu, 23 Nov 2017 18:56:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pbonzini@redhat.com
Cc: david@fromorbit.com, mhocko@kernel.org, akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

Paolo Bonzini wrote:
> On 23/11/2017 07:34, Tetsuo Handa wrote:
> >> Just fix the numa aware shrinkers, as they are the only ones that
> >> will have this problem. There are only 6 of them, and only the 3
> >> that existed at the time that register_shrinker() was changed to
> >> return an error fail to check for an error. i.e. the superblock
> >> shrinker, the XFS dquot shrinker and the XFS buffer cache shrinker.
> >
> > You are assuming the "too small to fail" memory-allocation rule
> > by ignoring that this problem is caused by fault injection.
> 
> Fault injection should also obey the too small to fail rule, at least by
> default.
> 

Pardon? Most allocation requests in the kernel are <= 32KB.
Such change makes fault injection useless. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
