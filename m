Message-ID: <3ED7DCF6.20206@us.ibm.com>
Date: Fri, 30 May 2003 15:36:38 -0700
From: Mingming Cao <cmm@us.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.5.70-mm2
References: <20030529012914.2c315dad.akpm@digeo.com>	<20030529042333.3dd62255.akpm@digeo.com>	<16087.47491.603116.892709@gargle.gargle.HOWL> <20030530133015.4f305808.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>>
>>Any hint on when -mm3 will be out,
> 
> 
> About ten hours hence, probably.
> 
> Welll ext3 has been a bit bumpy of course.  It's getting better, but I
> haven't yet been able to give it a 12-hour bash on the 4-way.  Last time I
> tried a circuit breaker conked; it lasted three hours but even ext3 needs
> electricity.  But three hours is very positive - it was hard testing.
> 
I run many fsx tests on mm2 on 8 way yesterday for a overnight run, 
before I saw your previous post.  Of course the tests failed with lots 
of error messages, but the good news is the system did not hang. Looking 
forward to mm3 out.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
