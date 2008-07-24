Date: Thu, 24 Jul 2008 12:26:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11156] New: Old kernels copy memory faster
 than new
Message-Id: <20080724122642.b8ef2ac6.akpm@linux-foundation.org>
In-Reply-To: <bug-11156-10286@http.bugzilla.kernel.org/>
References: <bug-11156-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: bugme-daemon@bugzilla.kernel.org, smal.root@gmail.com, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 24 Jul 2008 10:57:42 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11156
> 
>            Summary: Old kernels copy memory faster than new
>            Product: IO/Storage
>            Version: 2.5
>      KernelVersion: 2.6.24, 2.6.25
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Block Layer
>         AssignedTo: axboe@kernel.dk
>         ReportedBy: smal.root@gmail.com
> 
> 
> Latest working kernel version: 2.6.25
> Earliest failing kernel version: 2.6.24
> Distribution: Slackware 10-12
> 
> First machine:
> CPU - AMD Athlon3600+(2______)
> Chipset - nForce 6150(MCP51)
> RAM - 3G DDR2
> Video - internal GeForce6150
> Kernel - 2.6.25.4(own built)
> Copy speed - 1.7GByte/s
> 
> on another kernel:
> Kernel - 2.6.23.5(own built)
> Copy speed - 43.5GByte/s
> --------------------------------------------
> Second machine:
> CPU - PII-350
> MB i440BX
> RAM - 128M SDRAM
> Video - 3DFX Voodoo3
> Kernel - 2.6.21.5(Vanila from slackware distribution)
> Copy speed - 11.3GByte/s
> 
> Steps to reproduce:
> dd if=/dev/zero of=/dev/null bs=16M count=10000
> 

lol.  OK, who did that?

Perhaps ZERO_PAGE changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
