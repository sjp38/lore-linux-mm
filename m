Message-ID: <413CD4FF.8070408@sgi.com>
Date: Mon, 06 Sep 2004 16:22:07 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
References: <413CB661.6030303@sgi.com> <20040906131027.227b99ac.akpm@osdl.org>
In-Reply-To: <20040906131027.227b99ac.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, piggin@cyberone.com.au, mbligh@aracnet.com, kernel@kolivas.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

> 
> That being said, your tests are interesting.  There's a wide spread of
> results across different kernel versions and across different swappiness
> settings.  But the question is: which behaviour is correct for your users,
> and why?
> 

Andrew,

Behavior more like that of 2.6.5 and 2.6.6 is what we would like to see, I 
think.  We have had problems in the past with a single large HPC application 
that runs for a long time then wants to push its data out quickly.  What 
happens to us in 2.4.21 is that the page cache pages swap out the user pages, 
and that is somethine we would like to avoid, since it can reduce the data
rate significantly.

We were planning on suggesting that such users set swappiness=0 to give
user pages priority over the page cache pages.  But it doesn't look like that 
works very well in the more recent kernels.

One (perhaps) desirable feature would be for intermediate values of swappiness 
to have behavior in between the two extremes (mapped pages have higher 
priority vs page cache pages having priority over unreferenced mapped pages),
so that one would have finer grain control over the amount of swap used.  I'm 
not sure how to achieve such a goal, however.  :-)

On a separate issue, the response to my proposal for a mempolicy to control
allocation of page cache pages has been <ahem> underwhelming.

(See: http://marc.theaimsgroup.com/?l=linux-mm&m=109416852113561&w=2
  and  http://marc.theaimsgroup.com/?l=linux-mm&m=109416852416997&w=2 )

I wonder if this is because I just posted it to linux-mm or its not fleshed 
out enough yet to be interesting?

Thanks,
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
