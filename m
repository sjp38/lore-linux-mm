Received: from mercury.it.wmich.edu (localhost [127.0.0.1])
	by mercury.localmail (8.1340.2.132/20030819a) with SMTP id h7TFgvTS005431
	for <linux-mm@kvack.org>; Fri, 29 Aug 2003 11:42:57 -0400 (EDT)
Message-ID: <3F4F747E.7020601@wmich.edu>
Date: Fri, 29 Aug 2003 11:42:54 -0400
From: Ed Sweetman <ed.sweetman@wmich.edu>
MIME-Version: 1.0
Subject: Re: 2.6.0-test4-mm3
References: <20030828235649.61074690.akpm@osdl.org>
In-Reply-To: <20030828235649.61074690.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test4/2.6.0-test4-mm3/
> 
> 
> . Lots of small fixes.


It seems that since test3-mm2 ...possibly mm3, my kernels just hang 
after loading the input driver for the pc speaker.  Now directly after 
this on test3-mm1 serio loads.
  serio: i8042 AUX port at 0x60,0x64 irq 12
input: AT Set 2 keyboard on isa0060/serio0
serio: i8042 KBD port at 0x60,0x64 irq 1

I'm guessing this is where the later kernels are hanging.
I checked and i dont see any serio/input patches since mm1 in test3 but 
every mm kernel i've tried since mm3 hangs at the same point where as 
mm1 does not.  All have the same config.  I'm using acpi as well.  This 
is a via amd board.  I dont wanna send a general email with all kinds of 
extra info (.config and such) unless someone is interested in the 
problem and needs it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
