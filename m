Message-ID: <3E4DEB72.4010405@cyberone.com.au>
Date: Sat, 15 Feb 2003 18:25:38 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.61-mm1
References: <20030214231356.59e2ef51.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.61/2.5.61-mm1/
>
>. Jens has fixed the request queue aliasing problem and we are no longer
>  able to break the IO scheduler.  This was preventing the OSDL team from
>  running dbt2 against recent kernels, so hopefully that is all fixed up now.
>
>. The anticipatory scheduler is performing well.  I've included that now.
>
And for those interested, if you find unusual IO performance,
please try disabling AS and reporting results. Thanks.

echo 0 > /sys/block/?/iosched/antic_expire

This value defaults to 10 (ms). More than around 20 might do
funny though not harmful stuff due to a fragile bitshift.

Nick


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
