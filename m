Message-ID: <3F614E36.7030206@genebrew.com>
Date: Fri, 12 Sep 2003 00:40:22 -0400
From: Rahul Karnik <rahul@genebrew.com>
MIME-Version: 1.0
Subject: Re: [RFC] Enabling other oom schemes
References: <200309120219.h8C2JANc004514@penguin.co.intel.com> <3F614912.3090801@genebrew.com> <3F614C1F.6010802@nortelnetworks.com>
In-Reply-To: <3F614C1F.6010802@nortelnetworks.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Cc: rusty@linux.co.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chris Friesen wrote:
> If you have real, true strict overcommit, then it can cause you to have 
> errors much earlier than expected.

I was referring to the "strict overcommit" mode described in 
Documentation/vm/overcommit-accounting. To me, it sounded like it was 
describing modes that were alternatives to the proposed kernel panic on 
oom, and I was merely suggesting we use the same /proc/sys/vm method to 
specify oom behavior (maybe a string rather than numeric codes in case 
we have several such options in the future). Apologies if this is not 
related to what Rusty is talking about.

Thanks,
Rahul
--
Rahul Karnik
rahul@genebrew.com
http://www.genebrew.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
