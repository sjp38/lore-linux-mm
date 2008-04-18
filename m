Date: Thu, 17 Apr 2008 21:07:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-Id: <20080417210747.1ae21413.akpm@linux-foundation.org>
In-Reply-To: <3ae72650804171748y713c965bvbaf5de39e05ab555@mail.gmail.com>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	<20080417232441.GA19281@kroah.com>
	<3ae72650804171748y713c965bvbaf5de39e05ab555@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Cc: Greg KH <greg@kroah.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Apr 2008 02:48:19 +0200 "Kay Sievers" <kay.sievers@vrfy.org> wrote:

> On Fri, Apr 18, 2008 at 1:24 AM, Greg KH <greg@kroah.com> wrote:
> >
> > On Thu, Apr 17, 2008 at 04:03:31PM -0700, Andrew Morton wrote:
> >  >
> >  > I repulled all the trees an hour or two ago, installed everything on an
> >  > 8-way x86_64 box and:
> 
> >  > usb/sysfs:
> >  >
> >  > ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 17 (level, low) -> IRQ 17
> >  > uhci_hcd 0000:00:1d.0: UHCI Host Controller
> >  > uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
> >  > uhci_hcd 0000:00:1d.0: irq 17, io base 0x00002080
> >  > usb usb1: configuration #1 chosen from 1 choice
> >  > hub 1-0:1.0: USB hub found
> >  > hub 1-0:1.0: 2 ports detected
> >  > sysfs: duplicate filename '189:0' can not be created
> >
> >  Interesting, that's the new major:minor code.  I'll go poke at it...
> 
> Is this with the deprecated CONFIG_USB_DEVICE_CLASS=y? They have the
> same dev_t as usb_device and would be a reason for the duplicates.

The mac g5 is warning us about stuff too:

io scheduler deadline registered
io scheduler cfq registered
io scheduler bfq registered
proc_dir_entry '00' already registered
Call Trace:
[c00000017a0fbb80] [c000000000012018] .show_stack+0x58/0x1dc (unreliable)
[c00000017a0fbc30] [c00000000013f68c] .proc_register+0x218/0x260
[c00000017a0fbce0] [c00000000013fab8] .proc_mkdir_mode+0x40/0x74
[c00000017a0fbd60] [c0000000001f49a8] .pci_proc_attach_device+0x90/0x134
[c00000017a0fbe00] [c0000000005f0084] .pci_proc_init+0x68/0xa0
[c00000017a0fbe80] [c0000000005cbc94] .kernel_init+0x1ec/0x430
[c00000017a0fbf90] [c000000000026fc0] .kernel_thread+0x4c/0x68
nvidiafb: Device ID: 10de0141 
nvidiafb: CRTC0 analog not found

http://userweb.kernel.org/~akpm/config-g5.txt
http://userweb.kernel.org/~akpm/dmesg-g5.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
