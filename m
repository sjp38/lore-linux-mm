Message-ID: <4036C75E.1020407@movaris.com>
Date: Fri, 20 Feb 2004 18:50:06 -0800
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
References: <40363778.20900@movaris.com> <40368E00.3000505@cyberone.com.au>
In-Reply-To: <40368E00.3000505@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: kernelnewbies <kernelnewbies@nl.linux.org>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> 2.6 must start writeout, does it?

Sorry, but how can I tell?

> Can you post vmstat 1 logs for each kernel?

The 2.4.20 vmstat is attached (formatting inline is ugly) but I couldn't 
get a vmstat for 2.6.3. Running strace vmstat shows that it's dying when 
reading from /proc/stat with a SEGFAULT. I googled about this but didn't 
see anything.

Kirk


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
