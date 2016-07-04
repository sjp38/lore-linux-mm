Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D59F6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 11:17:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so69397545wme.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 08:17:08 -0700 (PDT)
Received: from mailout3.hostsharing.net (mailout3.hostsharing.net. [176.9.242.54])
        by mx.google.com with ESMTPS id uc7si3748204wjc.248.2016.07.04.08.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 08:17:07 -0700 (PDT)
Date: Mon, 4 Jul 2016 17:21:31 +0200
From: Lukas Wunner <lukas@wunner.de>
Subject: Re: kmem_cache_alloc fail with unable to handle paging request after
 pci hotplug remove.
Message-ID: <20160704152131.GA2766@wunner.de>
References: <577A7203.9010305@linux.intel.com>
 <CAJZ5v0ji9pVgAZZJT+RG83RNE4-GgJAp88Mw2ddVt3H6eHG72g@mail.gmail.com>
 <577A7B0A.4090107@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <577A7B0A.4090107@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathias Nyman <mathias.nyman@linux.intel.com>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, USB <linux-usb@vger.kernel.org>, acelan@gmail.com

On Mon, Jul 04, 2016 at 06:04:42PM +0300, Mathias Nyman wrote:
> On 04.07.2016 17:25, Rafael J. Wysocki wrote:
> > On Mon, Jul 4, 2016 at 4:26 PM, Mathias Nyman <mathias.nyman@linux.intel.com> wrote:
> > > AceLan Kao can get his DELL XPS 13 laptop to hang by plugging/un-plugging
> > > a USB 3.1 key via thunderbolt port.
> > > 
> > > Allocating memory fails after this, always pointing to NULL pointer or
> > > page request failing in get_freepointer() called by
> > > kmalloc/kmem_cache_alloc.
> > > 
> > > Unplugging a usb type-c device from the thunderbolt port on Alpine Ridge
> > > based systems like this one will hotplug remove PCI bridges together
> > > with the USB xhci controller behind them.

Yes, that matches with the lspci output you've posted, the whole
Thunderbolt controller is gone after unplug. Perhaps it's powered
down? What does "lspci -vvvv -s 00:1d.6" say? (Does the root port
still have a link to the Thunderbolt controller?)

Best regards,

Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
