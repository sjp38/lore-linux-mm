Message-ID: <3F63FC82.8070008@nortelnetworks.com>
Date: Sun, 14 Sep 2003 01:28:34 -0400
From: Chris Friesen <cfriesen@nortelnetworks.com>
MIME-Version: 1.0
Subject: Re: [RFC] Enabling other oom schemes
References: <200309120219.h8C2JANc004514@penguin.co.intel.com>	 <20030913174825.GB7404@mail.jlokier.co.uk> <1063476152.24473.30.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jamie Lokier <jamie@shareable.org>, rusty@linux.co.intel.com, riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Robert Love wrote:
> On Sat, 2003-09-13 at 13:48, Jamie Lokier wrote:
> 
> 
>>Also, when the OOM condition is triggered I'd like the system to
>>reboot, but first try for a short while to unmount filesystems cleanly.
>>
>>Any chance of those things?

<snip>

> I do like all of this, however, and want to see some different OOM
> killers.


One thing that we've done, and that others may find useful, is to allow 
processes to become immune to the oom-killer as long as they stay under 
a certain amount of memory allocated.

We added a syscall that specifies a certain number of pages of memory. 
As long as the process' memory utilization remains under that amount, 
the oom-killer will not kill it.

In our case we are on a mostly-embedded system, and have a pretty good 
idea what will be running.  This lets us engineer the critical apps to 
be immune, while still allowing memory to be freed up by killing 
non-critical applications.

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
