Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5830E6B006E
	for <linux-mm@kvack.org>; Thu, 14 May 2015 07:31:04 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so90523806wic.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 04:31:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf4si8989490wib.67.2015.05.14.04.31.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 04:31:02 -0700 (PDT)
Date: Thu, 14 May 2015 13:31:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514113101.GD6799@dhcp22.suse.cz>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514092301.GB6799@dhcp22.suse.cz>
 <20150514103542.GB5066@rei.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514103542.GB5066@rei.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, Nikolay Borisov <kernel@kyup.com>

On Thu 14-05-15 12:35:43, Cyril Hrubis wrote:
> Hi!
> > --- a/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> > +++ b/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> > @@ -158,17 +158,12 @@ testcase_21()
> >  # Case 22 - 24: Test limit_in_bytes will be aligned to PAGESIZE
> >  testcase_22()
> >  {
> > -	test_limit_in_bytes $((PAGESIZE-1)) $PAGESIZE 0
> > +	test_limit_in_bytes $((PAGESIZE-1)) 0 0
> >  }
> >  
> >  testcase_23()
> >  {
> > -	test_limit_in_bytes $((PAGESIZE+1)) $((PAGESIZE*2)) 0
> > -}
> > -
> > -testcase_24()
> > -{
> > -	test_limit_in_bytes 1 $PAGESIZE 0
> > +	test_limit_in_bytes $((PAGESIZE+1)) $((PAGESIZE)) 0
> >  }
> 
> That would fail on older kernels without the patch, woudln't it?

Yes it will. I thought those would be using some stable release (I do
not have much idea about the release process of ltp...). You are
definitely right that a backward compatible way is better. I will cook
up a patch later today.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
