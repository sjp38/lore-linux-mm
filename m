Message-ID: <403A2F89.4070405@movaris.com>
Date: Mon, 23 Feb 2004 08:51:21 -0800
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
References: <40363778.20900@movaris.com> <20040222231903.5f9ead5c.akpm@osdl.org>
In-Reply-To: <20040222231903.5f9ead5c.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: kernelnewbies@nl.linux.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

> I'd be wondering if your disk system is correctly running in DMA mode.

Apparently support for my hardware isn't magically preset in 2.6.3 as it 
was somehow in 2.4. After including it in the kernel the values returned 
by hdparm -Tt /dev/hda/ were sped up by a factor of 10! Thanks!

But...

> On my 256MB test box, mem01 takes 31 seconds under 2.4.25, 25 seconds
> under 2.6.3-mm3.

...I'm still seeing a factor of two speed slowdown between 2.4.20 and 
2.6.3. Would it help to do a vmstat log/graph for the new results?

Kirk


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
