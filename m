Message-Id: <4.3.2.7.2.20010325123201.00be27d0@mail.fluent-access.com>
Date: Sun, 25 Mar 2001 12:47:11 -0800
From: Stephen Satchell <satch@fluent-access.com>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <3ABE0F32.5255DF30@evision-ventures.com>
References: <E14gVQf-00056B-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

At 05:30 PM 3/25/01 +0200, you wrote:
> > Ultra reliable systems dont contain memory allocators. There are good 
> reasons
> > for this but the design trade offs are rather hard to make in a real world
> > environment
>
>I esp. they run on CPU's without a stack or what?

No dynamic memory allocation AT ALL.  That includes the prohibition of a 
stack.  I've seen avionics-loop systems that abstract a stack but the 
"allocators" are part of the application and are designed to fall over 
gracefully when they become full -- but getting this past a project manager 
is hard, as it should be.

Then there are those systems with rather interesting watchdog timers.  If 
you don't tickle them just right, they fire and force a restart.  The 
nastiest of these required that you send four specific values to a specific 
I/O port, and the hardware looked to see if the values violated certain 
timing guidelines.  If you sent the code too early or too late, or if the 
value in the sequence was incorrect, BAM.  The hardware was designed by a 
guy with some rather interesting experiences with software "engineers" 
dealing with watchdog timers...

Satch
   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
