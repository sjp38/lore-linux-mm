Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 811C66B025E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 03:25:01 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l68so214670046wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 00:25:01 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id a2si1035283wmc.91.2016.03.17.00.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 00:25:00 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id l68so12749136wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 00:25:00 -0700 (PDT)
Date: Thu, 17 Mar 2016 08:24:56 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() &
 unmapped_area_topdown()
Message-ID: <20160317072456.GA2522@gmail.com>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
 <20160316203657.GA29061@infradead.org>
 <1458162041.14723.32.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1458162041.14723.32.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Rik van Riel <riel@redhat.com> wrote:

> On Wed, 2016-03-16 at 13:36 -0700, Christoph Hellwig wrote:
> > On Wed, Mar 16, 2016 at 05:10:34PM +0000, Olu Ogunbowale wrote:
> > > 
> > > From: Olujide Ogunbowale <Olu.Ogunbowale@imgtec.com>
> > > 
> > > Export the memory management functions, unmapped_area() &
> > > unmapped_area_topdown(), as GPL symbols; this allows the kernel to
> > > better support process address space mirroring on both CPU and
> > > device
> > > for out-of-tree drivers by allowing the use of vm_unmapped_area()
> > > in a
> > > driver's file operation get_unmapped_area().
> > No new exports without in-tree drivers.  How about you get started
> > to get your drives into the tree first?
> 
> The drivers appear to require the HMM framework though,
> which people are also reluctant to merge without the
> drivers.
> 
> How do we get past this chicken & egg situation?

Submit the export together with the drivers for review and Cc: VM folks - it all 
looks pretty small on the VM side.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
