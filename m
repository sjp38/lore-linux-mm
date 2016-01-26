Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 009BF6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:31:19 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id 123so108332332wmz.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 06:31:18 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id j6si5887099wmj.0.2016.01.26.06.31.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 06:31:14 -0800 (PST)
Date: Tue, 26 Jan 2016 14:31:02 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 0/2 v2] set_memory_xx fixes
Message-ID: <20160126143102.GP10826@n2100.arm.linux.org.uk>
References: <1453789989-13260-1-git-send-email-mika.penttila@nextfour.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453789989-13260-1-git-send-email-mika.penttila@nextfour.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mika.penttila@nextfour.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 26, 2016 at 08:33:07AM +0200, mika.penttila@nextfour.com wrote:
> Recent changes (4.4.0+) in module loader triggered oops on ARM.
> 
> The module in question is in-tree module :
> drivers/misc/ti-st/st_drv.ko

I don't see a reason for these to be applied together, they each look
like stand-alone changes.

I'd like to apply the ARM (32-bit) change, but as it incorporates ARM64
changes, I either need an ack from ARM64 people, or I need the ARM64
code split out.  Please re-send, copying the ARM64 maintainers too,
optionally splitting the first patch up.

Thanks.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
