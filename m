Date: Tue, 6 Feb 2007 01:22:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 'cat /proc/interrupts' memleak
Message-Id: <20070206012203.c86f81ad.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702061113060.12147@Soyuz-KT.TeNet.Odessa.UA>
References: <Pine.LNX.4.64.0702022205470.17599@Soyuz-KT.TeNet.Odessa.UA>
	<20070205222927.095cb0d9.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702061113060.12147@Soyuz-KT.TeNet.Odessa.UA>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rus V. Brushkoff" <rus@SoyuzKT.Od.UA>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Feb 2007 11:13:51 +0200 (EET) "Rus V. Brushkoff" <rus@SoyuzKT.Od.UA> wrote:

> On Mon, 5 Feb 2007, Andrew Morton wrote:
> 
> :>   Doing in loop cat /proc/interrupts leaks memory in the system, which can 
> :> be observerd by top. Seems like config depended, so one is attached.
> :
> :I can't reproduce it here.  Can you please monitor /proc/meminfo and
> :/proc/slabinfo, work out where the memory is going to?
> 
> Memory logs while running in loop 'cat /proc/interrupts' attached.

I can't see much evidence of a leak there.

File "4" has MemFree:       1790496 kB
File "1" has MemFree:       1790504 kB

Mayeb you should let it run for longer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
