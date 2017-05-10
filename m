Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96CDB280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 04:46:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t12so20022777pgo.7
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:46:07 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id k20si2469676pfg.41.2017.05.10.01.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 01:46:06 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id 64so3265371pgb.3
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:46:06 -0700 (PDT)
Date: Wed, 10 May 2017 01:46:03 -0700
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: Re: [PATCH] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170510084602.qchu4psnughxrmsz@lostoracle.net>
References: <20170510065328.9215-1-nick.desaulniers@gmail.com>
 <20170510071511.GA31466@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510071511.GA31466@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> You can add

Something that's not clear to me when advised to add, should I be
uploading a v3 with your acked by? I think I got that wrong the last
time I asked (which was my first patch to Linux).

> But I still do not understand which part of the code is undefined and
> why.

It's not immediately clear to me either, but it's super later here...

>  is this a bug in -Wunsequenced in Clang

Possibly, I think I already found one earlier tonight.

https://bugs.llvm.org/show_bug.cgi?id=32985

Tomorrow, I'll try to cut down a test case to see if this is indeed a
compiler bug.  Would you like me to change the commit message to call
this just a simple clean up, in the meantime?

Thanks,
~Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
