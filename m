Message-ID: <3F614C1F.6010802@nortelnetworks.com>
Date: Fri, 12 Sep 2003 00:31:27 -0400
From: Chris Friesen <cfriesen@nortelnetworks.com>
MIME-Version: 1.0
Subject: Re: [RFC] Enabling other oom schemes
References: <200309120219.h8C2JANc004514@penguin.co.intel.com> <3F614912.3090801@genebrew.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rahul Karnik <rahul@genebrew.com>
Cc: rusty@linux.co.intel.com, riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rahul Karnik wrote:
> Rusty Lynch wrote:
> 
>> The patch below uses a notifier list for other components to register
>> to be called when an out of memory condition occurs.
> 
> 
> How does this interact with the overcommit handling? Doesn't strict 
> overcommit also not oom, but rather return a memory allocation error? 
> Could we not add another overcommit mode where oom conditions cause a 
> kernel panic?

If you have real, true strict overcommit, then it can cause you to have 
errors much earlier than expected.

Imagine a process that consumes 51% of memory.  With strict overcommit, 
that process cannot fork() since there is not enough memory.

Chris



-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
