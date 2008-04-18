Received: by yw-out-1718.google.com with SMTP id 6so444296ywa.26
        for <linux-mm@kvack.org>; Fri, 18 Apr 2008 15:01:43 -0700 (PDT)
Message-ID: <86802c440804181501w4e9563f2oe154c0744076e91e@mail.gmail.com>
Date: Fri, 18 Apr 2008 15:01:43 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] - Increase MAX_APICS for large configs
In-Reply-To: <20080418211423.GA4151@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080416163936.GA23099@sgi.com> <20080417110727.GA942@elte.hu>
	 <20080418211423.GA4151@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, mike travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 18, 2008 at 2:14 PM, Jack Steiner <steiner@sgi.com> wrote:
> On Thu, Apr 17, 2008 at 01:07:27PM +0200, Ingo Molnar wrote:
>  >
>  > * Jack Steiner <steiner@sgi.com> wrote:
>  >
>  > > Increase the maximum number of apics when running very large
>  > > configurations. This patch has no affect on most systems.
>  >
>  > x86.git overnight random-qa testing found a boot crash and i bisected it
>  > down to this patch. The config is:
>  >
>  >  http://redhat.com/~mingo/misc/config-Thu_Apr_17_10_17_14_CEST_2008.bad
>  >
>  > the failure is attached below. (I needed the exact boot parameters
>  > listed in that bootup log to see this failure.)
>  >
>  > it seems to be CONFIG_MAXSMP=y triggers the new more-apic-ids code and
>  > that causes some breakage elsewhere. [btw., this again shows how useful
>  > the CONFIG_MAXSMP debug feature is!]
>  >
>  >       Ingo
>  >
>  > [    0.000000] Linux version 2.6.25-rc9-sched-devel.git-x86-latest.git (mingo@dione) (gcc version 4.2.3) #260 SMP Thu Apr 17 10:58:11 CEST 2008
>  > [    0.000000] Command line: root=/dev/sda6 console=ttyS0,115200 earlyprintk=serial,ttyS0,115200 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 profile=0 nosmp highres=0 nolapic_timer hpet=disable idle=poll highmem=512m nopat acpi=off
>  > [    0.000000] BIOS-provided physical RAM map:
>
>  Has anyone seen this failure?? (Using git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git
>  from 4/18 AM).
>
>  I tried to reproduce the above failure on a small system & was not successful.
>
>  Switched to a larger system (XE310 Intel-based 8p, 6GB). All attempts to boot fail
>  with the following. I backed out the MAX_APIC change, & changed NR_CPUS=8. Still fails.
>
>         ...
>         [   32.010000] ehci_hcd 0000:00:1d.7: port 6 high speed
>         [   32.010000] ehci_hcd 0000:00:1d.7: GetStatus port 6 status 001005 POWER sig=se0 PE CONNECT
>         [   32.054003] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
>         [   32.058003] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
>         [   32.062003] usb usb2: Product: UHCI Host Controller
>         [   32.066004] usb usb2: Manufacturer: Linux 2.6.25-x86-latest.git uhci_hcd
>         [   32.070004] usb usb2: SerialNumber: 0000:00:1d.0
>         [   32.074004] PCI: Found IRQ 10 for device 0000:00:1d.1
>         [   32.078004] PCI: Sharing IRQ 10 with 0000:00:1f.2
>         [   32.082005] PCI: Sharing IRQ 10 with 0000:00:1f.3
>         [   32.086005] PCI: Sharing IRQ 10 with 0000:04:00.1
>         [   32.090005] PCI: Setting latency timer of device 0000:00:1d.1 to 64
>         [   32.094005] uhci_hcd 0000:00:1d.1: UHCI Host Controller
>         [   32.098006] usb 1-6: new high speed USB device using ehci_hcd and address 2
>         [   32.102006] nommu_map_single: overflow 1af757720+8
>
>  Full log:
>
>
>  [    0.000000] Linux version 2.6.25-x86-latest.git (root@cleopatra1) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-52)) #2 SMP Fri Apr 18 09:36:33 CDT 2008
>  [    0.000000] Command line: root=/dev/sda2 console=ttyS1,38400n8 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 profile=0 nosmp highres=0 nolapic_timer hpet=disable idle=poll highmem=512m nopat acpi=off

how about without acpi=off?

can you make sure acpi=off works with previous kernel in that box?

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
