Message-ID: <40368E00.3000505@cyberone.com.au>
Date: Sat, 21 Feb 2004 09:45:20 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
References: <40363778.20900@movaris.com>
In-Reply-To: <40363778.20900@movaris.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirk True <ktrue@movaris.com>
Cc: kernelnewbies <kernelnewbies@nl.linux.org>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>


Kirk True wrote:

> Hi all,
>
> Executing the LTP "mem01" VM test shows a huge time discrepancy 
> between 2.4.20 and 2.6.3. Under 2.4.20 the total time is around 5 
> seconds, while under 2.6.3 the system seems to hang for nearly a minute.
>
> Where in particular should I start to look to see if it's a 
> configuration/environment issue or a real problem? What other 
> information would be helpful to know?
>

2.6 must start writeout, does it?
Can you post vmstat 1 logs for each kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
