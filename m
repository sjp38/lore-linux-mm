Message-ID: <41FF45EA.5010908@hob.de>
Date: Tue, 01 Feb 2005 10:03:38 +0100
From: Christian Hildner <christian.hildner@hob.de>
MIME-Version: 1.0
Subject: Re: Kernel 2.4.21 hangs up
References: <20050201082001.43454.qmail@web51102.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: baswaraj kasture <kbaswaraj@yahoo.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

baswaraj kasture schrieb:

>Hi,
>
>I compiled kernel 2.4.21 with intel compiler .
>While booting it hangs-up . further i found that it
>hangsup due to call to "calibrate_delay" routine in
>"init/main.c". Also found that loop in the
>callibrate_delay" routine goes infinite.When i comment
>out the call to "callibrate_delay" routine, it works
>fine.Even compiling "init/main.c" with "-O0" works
>fine. I am using IA-64 (Intel Itanium 2 ) with EL3.0.
>
>Any pointers will be great help.
>
- Download ski from http://www.hpl.hp.com/research/linux/ski/download.php
- Compile your kernel for the simulator
- set simulator breakpoint at calibrate_delay
- look at ar.itc and cr.itm (cr.itm must be greater than ar.itc)

Or for debugging on hardware:
-run into loop, press the TOC button, reboot and analyze the dump with 
efi shell + errdump init

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
