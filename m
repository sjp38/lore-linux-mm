Date: Sun, 22 Feb 2004 23:19:03 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
Message-Id: <20040222231903.5f9ead5c.akpm@osdl.org>
In-Reply-To: <40363778.20900@movaris.com>
References: <40363778.20900@movaris.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirk True <ktrue@movaris.com>
Cc: kernelnewbies@nl.linux.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Kirk True <ktrue@movaris.com> wrote:
>
>  Executing the LTP "mem01" VM test shows a huge time discrepancy between 
>  2.4.20 and 2.6.3. Under 2.4.20 the total time is around 5 seconds, while 
>  under 2.6.3 the system seems to hang for nearly a minute.

I'd be wondering if your disk system is correctly running in DMA mode.

On my 256MB test box, mem01 takes 31 seconds under 2.4.25, 25 seconds
under 2.6.3-mm3.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
