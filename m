Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE676B0256
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 08:03:49 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p65so69678291wmp.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 05:03:49 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id u6si15250366wje.42.2016.03.07.05.03.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 05:03:47 -0800 (PST)
Date: Mon, 7 Mar 2016 13:03:38 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: 4.5.0-rc6: kernel BUG at ../mm/memory.c:1879
Message-ID: <20160307130338.GI19428@n2100.arm.linux.org.uk>
References: <nbjnq6$fim$1@ger.gmane.org>
 <56DD795C.9020903@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DD795C.9020903@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Matwey V. Kornilov" <matwey.kornilov@gmail.com>, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 07, 2016 at 01:51:40PM +0100, Vlastimil Babka wrote:
> [+CC ARM, module maintainers/lists]
> 
> On 03/07/2016 12:14 PM, Matwey V. Kornilov wrote:
> >
> >Hello,
> >
> >I see the following when try to boot 4.5.0-rc6 on ARM TI AM33xx based board.
> >
> >     [   13.907631] ------------[ cut here ]------------
> >     [   13.912323] kernel BUG at ../mm/memory.c:1879!
> 
> That's:
> BUG_ON(addr >= end);
> 
> where:
> end = addr + size;
> 
> All these variables are unsigned long, so they overflown?
> 
> I don't know ARM much, and there's no code for decodecode, but if I get the
> calling convention correctly, and the registers didn't change, both addr is
> r1 and size is r2, i.e. both bf006000. Weird.

A fix has been recently merged for this.  Look out for
"ARM: 8544/1: set_memory_xx fixes"

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
