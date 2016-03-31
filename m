Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 834416B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:09:01 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id 127so1384254wmu.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 16:09:01 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id e18si13866711wjx.104.2016.03.31.16.09.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 16:09:00 -0700 (PDT)
Date: Fri, 1 Apr 2016 00:08:45 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Issue with ioremap
Message-ID: <20160331230845.GN19428@n2100.arm.linux.org.uk>
References: <CAGnW=BYw9iqm8BpuWrxgcvXV3wwvHcvMtynPeHUGHHiZfPmfuA@mail.gmail.com>
 <20160331200147.GA20530@jcartwri.amer.corp.natinst.com>
 <56FDAA66.2000505@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56FDAA66.2000505@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Josh Cartwright <joshc@ni.com>, punnaiah choudary kalluri <punnaia@xilinx.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Sergey Dyasly <dserrg@gmail.com>, Arnd Bergmann <arnd.bergmann@linaro.org>

On Thu, Mar 31, 2016 at 03:53:26PM -0700, Laura Abbott wrote:
> (cc linux-arm)
> 
> On 03/31/2016 01:01 PM, Josh Cartwright wrote:
> >The driver _currently_ expects the virtual address to be 16M aligned,
> >but is that a hard requirement?  It seems possible that the driver could
> >be written without this assumption, correct?
> >
> >This would mean that the driver would need to maintain the cs/cycles
> >configuration state outside of the mapped virtual address, and then
> >calculate + add the calculated offset to the base.  Would that work?
> >I had been meaning to give it a try, but haven't gotten around to it.
> 
> I was curious so I took a look and this seems to be caused by

The driver is most likely buggy in the way Josh has identified.  The
peripheral device has no clue what virtual address is used to access
it, all it sees is the address on the bus.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
