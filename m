Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 591FF6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 03:49:23 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so133764100lfa.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 00:49:23 -0700 (PDT)
Received: from mailout1.hostsharing.net (mailout1.hostsharing.net. [83.223.95.204])
        by mx.google.com with ESMTPS id c132si2692599wme.52.2016.07.05.00.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 00:49:21 -0700 (PDT)
Date: Tue, 5 Jul 2016 09:53:46 +0200
From: Lukas Wunner <lukas@wunner.de>
Subject: Re: kmem_cache_alloc fail with unable to handle paging request after
 pci hotplug remove.
Message-ID: <20160705075346.GA2918@wunner.de>
References: <577A7203.9010305@linux.intel.com>
 <CAJZ5v0ji9pVgAZZJT+RG83RNE4-GgJAp88Mw2ddVt3H6eHG72g@mail.gmail.com>
 <577A7B0A.4090107@linux.intel.com>
 <20160704152131.GA2766@wunner.de>
 <577A84B4.8020505@linux.intel.com>
 <CAMz9Wg9wEhjH9izB_11xoNe954urJcRhrjbbyk9b45+42Vx6bg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMz9Wg9wEhjH9izB_11xoNe954urJcRhrjbbyk9b45+42Vx6bg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AceLan Kao <acelan@gmail.com>
Cc: Mathias Nyman <mathias.nyman@linux.intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, USB <linux-usb@vger.kernel.org>

On Tue, Jul 05, 2016 at 11:00:21AM +0800, AceLan Kao wrote:
> These are logs from my machine.
> 
> *** Before plug-in the USB key
> 
> u@u-XPS-13-9xxx:~$ sudo lspci -vvvv -s 00:1c.0
> 00:1c.0 PCI bridge: Intel Corporation Device 9d10 (rev f1) (prog-if 00
> [Normal decode])
[...]
>                 LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+

The link is down (DLActive-), but the root port is a hotplug port,
so apparently with Alpine Ridge the controller is powered down if
nothing is plugged in and this results in the controller being
"unplugged" from the root port.

This looks less fishy than I originally thought, it's just very
different from the power management of pre Alpine Ridge controllers
on Macs (which is the only thing I'm really familiar with), where
the root port is not a hotplug port and the controller does not
disappear from the system when powered down. (It's config space
just becomes inaccessible.)

Best regards,

Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
