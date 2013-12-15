Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id 026AC6B0035
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 11:17:58 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id o10so1759286eaj.32
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 08:17:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si9821076eew.13.2013.12.15.08.17.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 08:17:57 -0800 (PST)
Date: Sun, 15 Dec 2013 16:17:54 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131215161754.GN11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131215155539.GM11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Dec 15, 2013 at 03:55:39PM +0000, Mel Gorman wrote:
> <SNIP>
> tlbflush micro benchmark
>                     3.13.0-rc3            3.13.0-rc3                3.4.69
>                        vanilla           nowalk-v2r7               vanilla
> Min    1        7.00 (  0.00%)        6.00 ( 14.29%)        5.00 ( 28.57%)
> Min    2        8.00 (  0.00%)        6.00 ( 25.00%)        4.00 ( 50.00%)
> Min    3       13.00 (  0.00%)       11.00 ( 15.38%)        9.00 ( 30.77%)
> Min    4       17.00 (  0.00%)       19.00 (-11.76%)       15.00 ( 11.76%)
> Mean   1       11.28 (  0.00%)       10.66 (  5.48%)        5.17 ( 54.13%)
> Mean   2       11.42 (  0.00%)       11.52 ( -0.85%)        9.04 ( 20.82%)
> Mean   3       23.43 (  0.00%)       21.64 (  7.64%)       10.92 ( 53.39%)
> Mean   4       35.33 (  0.00%)       34.17 (  3.28%)       19.55 ( 44.67%)
> Range  1        6.00 (  0.00%)        7.00 (-16.67%)        4.00 ( 33.33%)
> Range  2       23.00 (  0.00%)       36.00 (-56.52%)       19.00 ( 17.39%)
> Range  3       15.00 (  0.00%)       17.00 (-13.33%)       10.00 ( 33.33%)
> Range  4       29.00 (  0.00%)       26.00 ( 10.34%)        9.00 ( 68.97%)
> Stddev 1        1.01 (  0.00%)        1.12 ( 10.53%)        0.57 (-43.70%)
> Stddev 2        1.83 (  0.00%)        3.03 ( 66.06%)        6.83 (274.00%)
> Stddev 3        2.82 (  0.00%)        3.28 ( 16.44%)        1.21 (-57.14%)
> Stddev 4        6.65 (  0.00%)        6.32 ( -5.00%)        1.58 (-76.24%)
> Max    1       13.00 (  0.00%)       13.00 (  0.00%)        9.00 ( 30.77%)
> Max    2       31.00 (  0.00%)       42.00 (-35.48%)       23.00 ( 25.81%)
> Max    3       28.00 (  0.00%)       28.00 (  0.00%)       19.00 ( 32.14%)
> Max    4       46.00 (  0.00%)       45.00 (  2.17%)       24.00 ( 47.83%)
> 
> <SNIP>
> 
>           3.13.0-rc3  3.13.0-rc3      3.4.69
>              vanilla nowalk-v2r7     vanilla
> User          179.36      165.25       97.29
> System        153.59      155.07      128.32
> Elapsed      1439.52     1437.69     2802.01
> 

After I ran the test, I looked closer at the elapsed times and it was
due to a bug in the test setup itself. The tlbflush tests will need to
be rerun but ebizzy still has the problem where threads see very
different performance.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
