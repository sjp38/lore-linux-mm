Message-ID: <000d01bfda37$f34c3ee0$0a1e18ac@local>
From: "Manfred Spraul" <manfred@colorfullife.com>
References: <87r99t8m2r.fsf@atlas.iskon.hr>
Subject: Re: shrink_mmap() change in ac-21
Date: Mon, 19 Jun 2000 23:47:14 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Zlatko Calusic" <zlatko@iskon.hr>
Return-Path: <owner-linux-mm@kvack.org>
To: zlatko@iskon.hr, alan@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>
> The reason is balancing of the DMA zone (which is much smaller on a
> 128MB machine than the NORMAL zone!). shrink_mmap() now happily evicts
> wrong pages from the memory and continues doing so until it finally
> frees enough pages from the DMA zone. That, of course, hurts caching
> as the page cache gets shrunk a lot without a good reason.
>
What caused the zone balancing?
Did you deliberately allocate GFP_DMA memory (sound card, old scsi card,
floppy disk, ...) or was it during "normal" operation?

--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
