Subject: Re: 2.6.0-test4-mm3
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <3F4F747E.7020601@wmich.edu>
References: <20030828235649.61074690.akpm@osdl.org>
	 <3F4F747E.7020601@wmich.edu>
Content-Type: text/plain
Message-Id: <1062172768.671.13.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: Fri, 29 Aug 2003 17:59:28 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Sweetman <ed.sweetman@wmich.edu>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-08-29 at 17:42, Ed Sweetman wrote:
> 
> It seems that since test3-mm2 ...possibly mm3, my kernels just hang 
> after loading the input driver for the pc speaker.  Now directly after 
> this on test3-mm1 serio loads.
>   serio: i8042 AUX port at 0x60,0x64 irq 12
> input: AT Set 2 keyboard on isa0060/serio0
> serio: i8042 KBD port at 0x60,0x64 irq 1

Please, take a look at
http://bugzilla.kernel.org/show_bug.cgi?id=1123

It's a problem with ACPI interrupt routing, it seems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
