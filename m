Message-ID: <45A89008.2030408@yahoo.com.au>
Date: Sat, 13 Jan 2007 18:53:44 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions
References: <20070112160104.GA5766@localhost.localdomain> <45A86291.8090408@yahoo.com.au> <20070113073643.GA4234@localhost.localdomain>
In-Reply-To: <20070113073643.GA4234@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

Ravikiran G Thirumalai wrote:
> On Sat, Jan 13, 2007 at 03:39:45PM +1100, Nick Piggin wrote:

>>What is the "CS time"?
> 
> 
> Critical Section :).  This is the maximal time interval I measured  from 
> t2 above to the time point we release the spin lock.  This is the hold 
> time I guess.
> 
> 
>>It would be interesting to know how long the maximal lru_lock *hold* time 
>>is,
>>which could give us a better indication of whether it is a hardware problem.
>>
>>For example, if the maximum hold time is 10ms, that it might indicate a
>>hardware fairness problem.
> 
> 
> The maximal hold time was about 3s.

Well then it doesn't seem very surprising that this could cause a 30s wait
time for one CPU in a 16 core system, regardless of fairness.

I guess most of the contention, and the lock hold times are coming from
vmscan? Do you know exactly which critical sections are the culprits?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
