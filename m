Date: Tue, 25 Jul 2000 14:38:33 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Inter-zone swapping
Message-ID: <20000725143833.E1396@redhat.com>
References: <20000722222740.A1475@cesarb.personal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000722222740.A1475@cesarb.personal>; from cesarb@nitnet.com.br on Sat, Jul 22, 2000 at 10:27:40PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Jul 22, 2000 at 10:27:40PM -0300, Cesar Eduardo Barros wrote:
> 
> Then would it be useful to "swap" a page from the DMA zone into the normal zone
> (and of course after that ending up swapping from the normal zone to the disk)?

Yes.  There are _lots_ of other possible applications for that sort of
non-IO-consuming relocation-style swapping, including memory
defragmentation (we really need that if we want to support things like
large page stuff on Intel boxes for user space).

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
