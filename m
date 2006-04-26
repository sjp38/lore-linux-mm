Message-ID: <444EC953.6060309@yahoo.com.au>
Date: Wed, 26 Apr 2006 11:13:55 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page host virtual assist patches.
References: <20060424123412.GA15817@skybase>	 <20060424180138.52e54e5c.akpm@osdl.org>  <444DCD87.2030307@yahoo.com.au>	 <1145953914.5282.21.camel@localhost>  <444DF447.4020306@yahoo.com.au>	 <1145964531.5282.59.camel@localhost>  <444E1253.9090302@yahoo.com.au> <1145974521.5282.89.camel@localhost>
In-Reply-To: <1145974521.5282.89.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:

>On Tue, 2006-04-25 at 22:13 +1000, Nick Piggin wrote:
>
>>Yes, that simple approach (presumably the guest ballooner allocates
>>memory from the guest and frees it to the host or something similar).
>>I'd be interested to see numbers from real workloads...
>>
>>I don't think the hva method is reasonable as it is. Let's see if we
>>can improve host->guest driven reclaiming first.
>>
>
>So you believe that the host->guest driven relaiming can be improved to
>a point where hva is superfluous. I do not believe that. Lets agree to
>

I'm not sure that it would ever be quite as fast, but I hope it
could be improved to the point that it is adequate. Yes.

>disagree here. Any findings in the hva code itself?
>

OK, we'll agree to disagree for now :)

I did start looking at the code but as you can see I only reviewed
patch 1 before getting sidetracked. I'll try to find some more time
to look at in the next few days.

Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
