Subject: Re: [RFT] balancing patch
References: <200003270803.AAA14950@google.engr.sgi.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 27 Mar 2000 19:33:41 +0200
In-Reply-To: kanoj@google.engr.sgi.com's message of "Mon, 27 Mar 2000 00:03:43 -0800 (PST)"
Message-ID: <qwwog80uxl6.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:

> People who are experiencing degraded performance in the latest 2.3
> releases due to overactive kswapd can apply the attached patch to 
> see whether it helps them. If you try the patch, and see that it
> helps, or hinders, your system performance, please let me know. 

I did not see degraded performance but tested it anyway with my shm
stress tests.

2.3.99-pre3 is the first release which handles 11.5GB shared mem
trashing on my 8GB machine without choking.

But adding your patch leads again to random process killed and other
oom situations when it has to go into swap.

Greetings
		Christoph

-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
