Date: 26 Jul 2005 17:17:54 +0200
Date: Tue, 26 Jul 2005 17:17:54 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Question about OOM-Killer
Message-ID: <20050726151754.GA9691@muc.de>
References: <20050725173514.107aaa1b.washer@trlp.com> <733170000.1122384572@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <733170000.1122384572@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: James Washer <washer@trlp.com>, marcelo.tosatti@cyclades.com, linux-mm@kvack.org, James Bottomley <James.Bottomley@SteelEye.com>
List-ID: <linux-mm.kvack.org>

> But that's really for ISA DMA, which nobody uses any more apart from the
> floppy disk, and the stone-tablet adaptor. For now, I'm guessing that if
> you remove that __GFP_DMA, your machine will be happier, but it's not
> the right fix. 

iirc the reason for that was that someone could load an old ISA SCSI controller
later as a module and it needs to handle that. Perhaps make it dependent
on CONFIG_ISA ? But even that would not help on distribution kernels.
Another way would be to check in PCI systems if there is a ISA 
bridge and for others assume ISA is there.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
