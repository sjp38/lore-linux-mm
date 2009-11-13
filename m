Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EAF7F6B004D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 20:28:19 -0500 (EST)
Received: by pwi9 with SMTP id 9so2006269pwi.6
        for <linux-mm@kvack.org>; Thu, 12 Nov 2009 17:28:18 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 12 Nov 2009 18:28:18 -0700
Message-ID: <e9c3a7c20911121728n647ab121l7f7c5827afdac887@mail.gmail.com>
Subject: GFP_ATOMIC versus GFP_NOWAIT
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Looking through the tree it seems that almost all drivers that need to
allocate memory in atomic contexts use GFP_ATOMIC.  I have been asking
dmaengine device driver authors to switch their atomic allocations to
GFP_NOWAIT.  The rationale being that in most cases a dma device is
either offloading an operation that will automatically fallback to
software when the descriptor allocation fails, or we can simply poll
and wait for the dma device to release some in use descriptors.  So it
does not make sense to grab from the emergency pools when the result
of an allocation failure is some additional cpu overhead.  Am I
correct in my nagging, and should this idea be spread outside of
drivers/dma/ to cut down on GFP_ATOMIC usage, or is this not a big
issue?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
