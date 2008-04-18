Received: by wa-out-1112.google.com with SMTP id m33so434724wag.8
        for <linux-mm@kvack.org>; Thu, 17 Apr 2008 17:48:19 -0700 (PDT)
Message-ID: <3ae72650804171748y713c965bvbaf5de39e05ab555@mail.gmail.com>
Date: Fri, 18 Apr 2008 02:48:19 +0200
From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: 2.6.25-mm1: not looking good
In-Reply-To: <20080417232441.GA19281@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	 <20080417232441.GA19281@kroah.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 18, 2008 at 1:24 AM, Greg KH <greg@kroah.com> wrote:
>
> On Thu, Apr 17, 2008 at 04:03:31PM -0700, Andrew Morton wrote:
>  >
>  > I repulled all the trees an hour or two ago, installed everything on an
>  > 8-way x86_64 box and:

>  > usb/sysfs:
>  >
>  > ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 17 (level, low) -> IRQ 17
>  > uhci_hcd 0000:00:1d.0: UHCI Host Controller
>  > uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
>  > uhci_hcd 0000:00:1d.0: irq 17, io base 0x00002080
>  > usb usb1: configuration #1 chosen from 1 choice
>  > hub 1-0:1.0: USB hub found
>  > hub 1-0:1.0: 2 ports detected
>  > sysfs: duplicate filename '189:0' can not be created
>
>  Interesting, that's the new major:minor code.  I'll go poke at it...

Is this with the deprecated CONFIG_USB_DEVICE_CLASS=y? They have the
same dev_t as usb_device and would be a reason for the duplicates.

Thanks,
Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
