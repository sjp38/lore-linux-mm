Date: Thu, 17 Apr 2008 16:24:41 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: 2.6.25-mm1: not looking good
Message-ID: <20080417232441.GA19281@kroah.com>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080417160331.b4729f0c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 04:03:31PM -0700, Andrew Morton wrote:
> 
> I repulled all the trees an hour or two ago, installed everything on an
> 8-way x86_64 box and:
> 
> 
> stack-protector:
> 
> Testing -fstack-protector-all feature
> No -fstack-protector-stack-frame!
> -fstack-protector-all test failed
> ------------[ cut here ]------------
> WARNING: at kernel/panic.c:369 __stack_chk_test+0x4b/0x51()
> Modules linked in:
> Pid: 1, comm: swapper Not tainted 2.6.25-mm1 #4
> 
> Call Trace:
>  [<ffffffff80256692>] ? print_modules+0x88/0x8f
>  [<ffffffff80237b70>] warn_on_slowpath+0x58/0x7f
>  [<ffffffff802388fe>] ? printk+0x67/0x69
>  [<ffffffff8034ec74>] ? debug_write_lock_after+0x18/0x1f
>  [<ffffffff8034ed43>] ? _raw_write_unlock+0x29/0x7b
>  [<ffffffff804f0254>] ? _write_unlock+0x9/0xb
>  [<ffffffff8023d25e>] ? insert_resource+0xe3/0xea
>  [<ffffffff80237be2>] __stack_chk_test+0x4b/0x51
>  [<ffffffff8092f912>] kernel_init+0x16c/0x29e
>  [<ffffffff8020ce58>] child_rip+0xa/0x12
>  [<ffffffff8092f7a6>] ? kernel_init+0x0/0x29e
>  [<ffffffff8020ce4e>] ? child_rip+0x0/0x12
> 
> ---[ end trace da2bc9ee81defeda ]---
> 
> 
> usb/sysfs:
> 
> ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 17 (level, low) -> IRQ 17
> uhci_hcd 0000:00:1d.0: UHCI Host Controller
> uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
> uhci_hcd 0000:00:1d.0: irq 17, io base 0x00002080
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 2 ports detected
> sysfs: duplicate filename '189:0' can not be created

Interesting, that's the new major:minor code.  I'll go poke at it...

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
