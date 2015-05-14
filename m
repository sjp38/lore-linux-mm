Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6B16B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 05:21:49 -0400 (EDT)
Received: by wizk4 with SMTP id k4so232885926wiz.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 02:21:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id he1si3210983wib.34.2015.05.14.02.21.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 02:21:47 -0700 (PDT)
Date: Thu, 14 May 2015 11:21:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514092145.GA6799@dhcp22.suse.cz>
References: <55536DC9.90200@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55536DC9.90200@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, Cyril Hrubis <chrubis@suse.cz>

On Wed 13-05-15 18:29:13, Nikolay Borisov wrote:
> Hello,
> 
> I'm running the ltp version 20150420 and stock kernel 4.0 and I've
> observed that the memcg_function test is failing. Here is a relevant
> snipped from the log:
> 
> 
> memcg_function_test   14  TFAIL  :  ltpapicmd.c:190: process 5827 is not
> killed
> /opt/ltp/testcases/bin/memcg_lib.sh: line 210:  5843 Killed
>      $TEST_PATH/memcg_process $2 -s $3
> memcg_function_test   15  TPASS  :  process 5843 is killed
> /opt/ltp/testcases/bin/memcg_lib.sh: line 210:  5859 Killed
>      $TEST_PATH/memcg_process $2 -s $3
> memcg_function_test   16  TPASS  :  process 5859 is killed
> /opt/ltp/testcases/bin/memcg_lib.sh: line 210:  5877 Killed
>      $TEST_PATH/memcg_process $2 -s $3
> memcg_function_test   17  TPASS  :  process 5877 is killed
> /opt/ltp/testcases/bin/memcg_lib.sh: line 210:  5894 Killed
>      $TEST_PATH/memcg_process $2 -s $3
> memcg_function_test   18  TPASS  :  process 5894 is killed
> /opt/ltp/testcases/bin/memcg_lib.sh: line 210:  5911 Killed
>      $TEST_PATH/memcg_process $2 -s $3
> memcg_function_test   19  TPASS  :  process 5911 is killed
> /opt/ltp/testcases/bin/memcg_lib.sh: line 210:  5927 Killed
>      $TEST_PATH/memcg_process $2 -s $3
> memcg_function_test   20  TPASS  :  process 5927 is killed
> /opt/ltp/testcases/bin/memcg_lib.sh: line 210:  5942 Killed
>      $TEST_PATH/memcg_process $2 -s $3
> memcg_function_test   21  TPASS  :  process 5942 is killed
> memcg_function_test   22  TFAIL  :  ltpapicmd.c:190: input=4095,
> limit_in_bytes=0
> memcg_function_test   23  TFAIL  :  ltpapicmd.c:190: input=4097,
> limit_in_bytes=4096
> memcg_function_test   24  TFAIL  :  ltpapicmd.c:190: input=1,
> limit_in_bytes=0
> memcg_function_test   25  TPASS  :  return value is 0
> memcg_function_test   26  TPASS  :  return value is 1
> memcg_function_test   27  TPASS  :  return value is 1
> memcg_function_test   28  TPASS  :  return value is 1
> memcg_function_test   29  TPASS  :  force memory succeeded
> memcg_function_test   30  TFAIL  :  ltpapicmd.c:190: force memory should
> fail
> memcg_function_test   31  TPASS  :  return value is 0
> memcg_function_test   32  TPASS  :  return value is 0
> memcg_function_test   33  TPASS  :  return value is 0
> memcg_function_test   34  TPASS  :  return value is 0
> memcg_function_test   35  TPASS  :  return value is 1
> Running /opt/ltp/testcases/bin/memcg_process --mmap-anon -s 4096
> Warming up for test: 36, pid: 6128
> Process is still here after warm up: 6128
> memcg_function_test   36  TPASS  :  rss=4096/4096
> memcg_function_test   36  TPASS  :  rss=0/0
> Running /opt/ltp/testcases/bin/memcg_process --mmap-anon -s 4096
> Warming up for test: 37, pid: 6155
> Process is still here after warm up: 6155
> memcg_function_test   37  TPASS  :  rss=4096/4096
> memcg_function_test   37  TPASS  :  rss=0/0
> Running /opt/ltp/testcases/bin/memcg_process --mmap-anon -s 4096
> Warming up for test: 38, pid: 6182
> Process is still here after warm up: 6182
> memcg_function_test   38  TPASS  :  rss=4096/4096
> memcg_function_test   38  TPASS  :  rss=0/0
> <<<execution_status>>>
> initiation_status="ok"
> duration=135 termination_type=exited termination_id=5 corefile=no
> cutime=8 cstime=15
> <<<test_end>>>
> INFO: ltp-pan reported some tests FAIL
> LTP Version: 20150420
> 
> According to the file at :
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/controllers/memcg/functional/memcg_function_test.sh
> 
> 
> The failing test cases 14, 22, 23, 24 and 30 test respectively:
> 
> 14: Hogging memory like so: mmap(NULL, memsize, PROT_WRITE | PROT_READ,
> MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKED, 0, 0);

MAP_LOCKED will not trigger the OOM killer as explained
http://marc.info/?l=linux-mm&m=142122902313315&w=2. So this is expected
and Cyril is working on fixing the test case.

> # Case 22 - 24: Test limit_in_bytes will be aligned to PAGESIZE - The
> output clearly indicates that the limits in bytes is not being page
> aligned?

I can see
> memcg_function_test   22  TFAIL  :  ltpapicmd.c:190: input=4095,
> limit_in_bytes=0
> memcg_function_test   23  TFAIL  :  ltpapicmd.c:190: input=4097,
> limit_in_bytes=4096
> memcg_function_test   24  TFAIL  :  ltpapicmd.c:190: input=1,
> limit_in_bytes=0

So limit_in_bytes _is_ page aligned but we round down rather than up.

> Is this desired behavior, in which case ltp is broken or is it
> a genuine bug?

This behavior has changed by 3e32cb2e0a12 ("mm: memcontrol: lockless
page counters") introduced in 3.19. The change in rounding has been
pointed out during the review
http://marc.info/?l=linux-mm&m=141207518827336&w=2 but the conclusion
was that the original round up wasn't really much better
http://marc.info/?l=linux-mm&m=141226210316376&w=2 resp.
http://marc.info/?l=linux-mm&m=141234785111200&w=2

I will post fix for ltp in the reply

> 30: Again, it locks memory with mmap and then tries to see if
> force_empty would succeed. Expecting it to fail, but in this particular
> case it succeeds?

I am not sure I understand this testcase. It does:
	TEST_PATH/memcg_process --mmap-anon -s $PAGESIZE
	[...]
        echo 1 > memory.force_empty 2> /dev/null
        if [ $? -ne 0 ]; then
                result $PASS "force memory failed as expected"
        else    
                result $FAIL "force memory should fail"
        fi

and that means:
void mmap_anon()
{               
        static char *p; 
        
        if (!flag_allocated) {
                p = mmap(NULL, memsize, PROT_WRITE | PROT_READ,
                         MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
                if (p == MAP_FAILED)
                        err(1, "mmap(anonymous) failed");
                touch_memory(p, memsize);
        } else {
                if (munmap(p, memsize) == -1)
                        err(1, "munmap(anonymous) failed");
        }
}

so there is no mlock there. Why should the force reclaim fail then?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
