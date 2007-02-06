Date: Mon, 5 Feb 2007 22:29:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 'cat /proc/interrupts' memleak
Message-Id: <20070205222927.095cb0d9.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702022205470.17599@Soyuz-KT.TeNet.Odessa.UA>
References: <Pine.LNX.4.64.0702022205470.17599@Soyuz-KT.TeNet.Odessa.UA>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rus V. Brushkoff" <rus@SoyuzKT.Od.UA>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Feb 2007 22:07:37 +0200 (EET) "Rus V. Brushkoff" <rus@SoyuzKT.Od.UA> wrote:

>   Doing in loop cat /proc/interrupts leaks memory in the system, which can 
> be observerd by top. Seems like config depended, so one is attached.

I can't reproduce it here.  Can you please monitor /proc/meminfo and
/proc/slabinfo, work out where the memory is going to?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
