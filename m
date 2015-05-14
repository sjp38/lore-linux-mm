Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C96296B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 10:44:54 -0400 (EDT)
Received: by wizk4 with SMTP id k4so244186926wiz.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 07:44:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey16si14723748wid.49.2015.05.14.07.44.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 07:44:53 -0700 (PDT)
Date: Thu, 14 May 2015 16:44:20 +0200
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514144420.GA12884@rei>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514103148.GA5066@rei.suse.de>
 <20150514115641.GE6799@dhcp22.suse.cz>
 <20150514120142.GG5066@rei.suse.de>
 <20150514121248.GG6799@dhcp22.suse.cz>
 <20150514123816.GC6993@rei>
 <20150514143039.GI6799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514143039.GI6799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

Hi!
> Signed-off-by: Michal Hocko <miso@dhcp22.suse.cz>

                                 ^
			       forgotten git config user.email?
> ---
>  testcases/kernel/controllers/memcg/functional/memcg_function_test.sh | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh b/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> index cfc75fa730df..399c5614468a 100755
> --- a/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> +++ b/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> @@ -211,8 +211,8 @@ testcase_29()
>  	echo $pid > tasks
>  	kill -s USR1 $pid 2> /dev/null
>  	sleep 1
> -	echo $pid > ../tasks

This change breaks the testcase on older kernels:

./memcg_function_test.sh: line 215: echo: write error: Device or resource busy
memcg_function_test   29  TFAIL  :  ltpapicmd.c:190: force memory failed

$ uname -r
3.0.101-0.35-default

> +	# This expects that there is swap configured
>  	echo 1 > memory.force_empty
>  	if [ $? -eq 0 ]; then
>  		result $PASS "force memory succeeded"
> @@ -225,7 +225,7 @@ testcase_29()
>  
>  testcase_30()
>  {
> -	$TEST_PATH/memcg_process --mmap-anon -s $PAGESIZE &
> +	$TEST_PATH/memcg_process --mmap-lock2 -s $PAGESIZE &
>  	pid=$!
>  	sleep 1
>  	echo $pid > tasks

This part is OK.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
