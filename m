Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB6E6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 10:49:52 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so44575968wgb.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 07:49:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v5si39022601wjr.212.2015.05.14.07.49.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 07:49:50 -0700 (PDT)
Date: Thu, 14 May 2015 16:49:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514144949.GJ6799@dhcp22.suse.cz>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514103148.GA5066@rei.suse.de>
 <20150514115641.GE6799@dhcp22.suse.cz>
 <20150514120142.GG5066@rei.suse.de>
 <20150514121248.GG6799@dhcp22.suse.cz>
 <20150514123816.GC6993@rei>
 <20150514143039.GI6799@dhcp22.suse.cz>
 <20150514144420.GA12884@rei>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514144420.GA12884@rei>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 14-05-15 16:44:20, Cyril Hrubis wrote:
> Hi!
> > Signed-off-by: Michal Hocko <miso@dhcp22.suse.cz>
> 
>                                  ^
> 			       forgotten git config user.email?

Dohh...

> > ---
> >  testcases/kernel/controllers/memcg/functional/memcg_function_test.sh | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh b/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> > index cfc75fa730df..399c5614468a 100755
> > --- a/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> > +++ b/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> > @@ -211,8 +211,8 @@ testcase_29()
> >  	echo $pid > tasks
> >  	kill -s USR1 $pid 2> /dev/null
> >  	sleep 1
> > -	echo $pid > ../tasks
> 
> This change breaks the testcase on older kernels:

Yeah, my bad, I've started with this then changed it back but forgot to
add it to the commit. Sorry about that. Hopefully the correct one:
---
