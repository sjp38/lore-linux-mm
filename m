Date: Thu, 14 Sep 2000 21:20:05 +0200
From: Wichert Akkerman <wichert@cistron.nl>
Subject: Re: Running out of memory in 1 easy step
Message-ID: <20000914212004.A1304@cistron.nl>
References: <20000914145904.B18741@liacs.nl> <20000914175633.A7675@fred.muc.de> <20000914180825.B19822@liacs.nl> <20000914204325.A6015@fred.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000914204325.A6015@fred.muc.de>; from ak@muc.de on Thu, Sep 14, 2000 at 08:43:25PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Previously Andi Kleen wrote:
> The limit is actually 65536 I misremembered it. 
> The main purpose is probably to avoid the counter wrapping. 
> When get_unmapped_area failed you likely just ran out of virtual address space.

Not likely, there were still a couple hundreds of megabytes free and
the process had allocated about 1.5Gb of data.

Wichert.

-- 
  _________________________________________________________________
 /       Nothing is fool-proof to a sufficiently talented fool     \
| wichert@wiggy.net                   http://www.liacs.nl/~wichert/ |
| 1024D/2FA3BC2D 576E 100B 518D 2F16 36B0  2805 3CB8 9250 2FA3 BC2D |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
