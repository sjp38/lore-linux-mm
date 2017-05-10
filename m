Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A15DC280858
	for <linux-mm@kvack.org>; Wed, 10 May 2017 05:25:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o52so6599885wrb.10
        for <linux-mm@kvack.org>; Wed, 10 May 2017 02:25:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 138si2132762wmm.26.2017.05.10.02.25.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 02:25:07 -0700 (PDT)
Date: Wed, 10 May 2017 11:25:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170510092505.GH31466@dhcp22.suse.cz>
References: <20170510065328.9215-1-nick.desaulniers@gmail.com>
 <20170510071511.GA31466@dhcp22.suse.cz>
 <20170510084602.qchu4psnughxrmsz@lostoracle.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510084602.qchu4psnughxrmsz@lostoracle.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 10-05-17 01:46:03, Nick Desaulniers wrote:
> > You can add
> 
> Something that's not clear to me when advised to add, should I be
> uploading a v3 with your acked by? I think I got that wrong the last
> time I asked (which was my first patch to Linux).

If there are no further changes to the patch/changelog then it is not
necessary. The maintainer usually just grabs ackes and reviewed-bys
from the list.

> > But I still do not understand which part of the code is undefined and
> > why.
> 
> It's not immediately clear to me either, but it's super later here...

I would really like to understand that...
 
> >  is this a bug in -Wunsequenced in Clang
> 
> Possibly, I think I already found one earlier tonight.
> 
> https://bugs.llvm.org/show_bug.cgi?id=32985

this seems unrelated. I would try to report this and clarify in the llvm
bugzilla.

> Tomorrow, I'll try to cut down a test case to see if this is indeed a
> compiler bug.  Would you like me to change the commit message to call
> this just a simple clean up, in the meantime?

I would go with the following wording.
"
Clang and its -Wunsequenced emits a warning
(PUT THE FULL WARNING HERE).

While it is not clear to me whether the initialization code violates the
specification (6.7.8 par 19 (ISO/IEC 9899) looks it disagrees) the code
is quite confusing and worth cleaning up anyway. Fix this by reusing
sc.gfp_mask rather than the updated input gfp_mask parameter.
"
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
