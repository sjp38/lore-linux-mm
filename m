Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9472B6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 06:36:16 -0400 (EDT)
Received: by wizk4 with SMTP id k4so235225695wiz.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 03:36:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg7si3072795wib.78.2015.05.14.03.36.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 03:36:15 -0700 (PDT)
Date: Thu, 14 May 2015 12:35:43 +0200
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514103542.GB5066@rei.suse.de>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514092301.GB6799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514092301.GB6799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, Nikolay Borisov <kernel@kyup.com>

Hi!
> --- a/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> +++ b/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> @@ -158,17 +158,12 @@ testcase_21()
>  # Case 22 - 24: Test limit_in_bytes will be aligned to PAGESIZE
>  testcase_22()
>  {
> -	test_limit_in_bytes $((PAGESIZE-1)) $PAGESIZE 0
> +	test_limit_in_bytes $((PAGESIZE-1)) 0 0
>  }
>  
>  testcase_23()
>  {
> -	test_limit_in_bytes $((PAGESIZE+1)) $((PAGESIZE*2)) 0
> -}
> -
> -testcase_24()
> -{
> -	test_limit_in_bytes 1 $PAGESIZE 0
> +	test_limit_in_bytes $((PAGESIZE+1)) $((PAGESIZE)) 0
>  }

That would fail on older kernels without the patch, woudln't it?

If we are going to fix it, we should do that in backward compatible
fashion. So either we modify the testcases to accept both rounding up
and rounding down or choose what we expect based on kernel version.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
