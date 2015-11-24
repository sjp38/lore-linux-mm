Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFDD6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:01:32 -0500 (EST)
Received: by ioir85 with SMTP id r85so16179608ioi.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:01:32 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id wi5si12751500igb.3.2015.11.24.03.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 03:01:31 -0800 (PST)
Message-ID: <1448362882.32654.1.camel@ellerman.id.au>
Subject: Re: + arc-convert-to-dma_map_ops.patch added to -mm tree
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 24 Nov 2015 22:01:22 +1100
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA23075F44D3928@IN01WEMBXA.internal.synopsys.com>
References: <564b9e3a.DaXj5xWV8Mzu1fPX%akpm@linux-foundation.org>
	 <C2D7FE5348E1B147BCA15975FBA23075F44D2EEF@IN01WEMBXA.internal.synopsys.com>
	 <20151124075047.GA29572@lst.de>
	 <C2D7FE5348E1B147BCA15975FBA23075F44D3928@IN01WEMBXA.internal.synopsys.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "hch@lst.de" <hch@lst.de>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, arcml <linux-snps-arc@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, Anton Kolesov <Anton.Kolesov@synopsys.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>

On Tue, 2015-11-24 at 09:46 +0000, Vineet Gupta wrote:
> On Tuesday 24 November 2015 01:20 PM, hch@lst.de wrote:
> > Hi Vineet,
> > 
> > the original version went through the buildbot, which succeeded.  It seems
> > like the official buildbot does not support arc, and might benefit from
> > helping to set up an arc environment. 
> 
> I have in the past asked kisskb service folks - but haven't heard back from them.
> Stephan, Michael could you please add ARC toolchain to kisskb build service. I can
> buy you guys a beer (or some other beverage of choice) next time we meet :-)

Sure, where do I get a toolchain? Can I just build upstream binutils + GCC?

chers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
