Date: Fri, 29 Aug 2003 08:57:26 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test4-mm3
Message-Id: <20030829085726.452d7a3f.akpm@osdl.org>
In-Reply-To: <3F4F747E.7020601@wmich.edu>
References: <20030828235649.61074690.akpm@osdl.org>
	<3F4F747E.7020601@wmich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Sweetman <ed.sweetman@wmich.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Sweetman <ed.sweetman@wmich.edu> wrote:
>
> Andrew Morton wrote:
> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test4/2.6.0-test4-mm3/
> > 
> > 
> > . Lots of small fixes.
> 
> 
> It seems that since test3-mm2 ...possibly mm3, my kernels just hang 
> after loading the input driver for the pc speaker.  Now directly after 
> this on test3-mm1 serio loads.
>   serio: i8042 AUX port at 0x60,0x64 irq 12
> input: AT Set 2 keyboard on isa0060/serio0
> serio: i8042 KBD port at 0x60,0x64 irq 1
> 
> I'm guessing this is where the later kernels are hanging.
> I checked and i dont see any serio/input patches since mm1 in test3 but 
> every mm kernel i've tried since mm3 hangs at the same point where as 
> mm1 does not.  All have the same config.  I'm using acpi as well.  This 
> is a via amd board.  I dont wanna send a general email with all kinds of 
> extra info (.config and such) unless someone is interested in the 
> problem and needs it.

The only patch I can see in there is syn-multi-btn-fix.patch in test3-mm3,
which seems unlikely.

Have you tested 2.6.0-test4?  If that also fails then I'd be suspecting the
ACPI changes; there seem to be a few new problems in that area lately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
