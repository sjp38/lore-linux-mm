Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id EEA6C6B0083
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 01:58:16 -0400 (EDT)
Date: Mon, 9 Apr 2012 07:58:14 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: BUG: Bad rss-counter state
Message-ID: <20120409055814.GA292@x4>
References: <20120408113925.GA292@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120408113925.GA292@x4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>

On 2012.04.08 at 13:39 +0200, Markus Trippelsdorf wrote:
> I've hit the following warning after I've tried to link Firofox's libxul
> with "-flto -lto-partition=none" on my machine with 8GB memory. I've
> killed the process after it used all the memory and 90% of my swap
> space. Before the machine was rebooted I saw these messages:
> 
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813c380 idx:1 val:-1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813c380 idx:2 val:1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88021503bb80 idx:1 val:-1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fb643b80 idx:1 val:-1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fb643b80 idx:2 val:1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88021503bb80 idx:2 val:1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020a4ff800 idx:1 val:-1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020a4ff800 idx:2 val:1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813ce00 idx:1 val:-1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813ce00 idx:2 val:1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fadda680 idx:1 val:-1
> Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fadda680 idx:2 val:1

BTW, I'm not the only one that sees these messages. Here are two more
reports from Ubuntu beta testers:

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/963672
BUG: Bad rss-counter state mm:ffff88022107fb80 idx:1 val:-14
BUG: Bad rss-counter state mm:ffff88022107fb80 idx:2 val:14


https://bugs.launchpad.net/ubuntu/+source/linux/+bug/965709
BUG: Bad rss-counter state mm:c8fd9dc0 idx:1 val:-2
BUG: Bad rss-counter state mm:c8fd9dc0 idx:2 val:2
usb 5-1: USB disconnect, device number 2
usb 5-1: new low-speed USB device number 3 using uhci_hcd
input: Mega World Thrustmaster dual analog 3.2 as
/devices/pci0000:00/0000:00:1d.0/usb5/5-1/5-1:1.0/input/input13
generic-usb 0003:044F:B315.0004: input,hidraw1: USB HID v1.10 Gamepad
[Mega World Thrustmaster dual analog 3.2] on usb-0000:00:1d.0-1/input0
BUG: Bad rss-counter state mm:c8fd9dc0 idx:1 val:-2
BUG: Bad rss-counter state mm:c8fd9dc0 idx:2 val:2
BUG: Bad rss-counter state mm:dea3cc40 idx:1 val:-1
BUG: Bad rss-counter state mm:dea3cc40 idx:2 val:1

The pattern seem to be:
... idx:1 val:-x
... idx:2 val:x
for x=1,2,14

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
