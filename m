Date: 26 Jul 2005 15:53:07 +0200
Date: Tue, 26 Jul 2005 15:53:07 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Question about OOM-Killer
Message-ID: <20050726135307.GB96994@muc.de>
References: <20050718122101.751125ef.washer@trlp.com> <20050718123650.01a49f31.washer@trlp.com> <20050723130048.GA16460@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050723130048.GA16460@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: James Washer <washer@trlp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 23, 2005 at 10:00:48AM -0300, Marcelo Tosatti wrote:
> 
> James,
> 
> Can you send the OOM killer output? 
> 
> I dont know which devices part of an x86-64 system should 
> be limited to 16Mb of physical addressing. Andi? 

Could be old devices like the floppy (it does a single GFP_DMA
allocation). Or a few devices that have >16MB limits (like aacraid
or some old sound chips) but there is no other zone for them
right now.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
