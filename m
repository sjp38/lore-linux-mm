Date: Wed, 5 Jul 2000 22:53:34 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: PATCH: vm/kswapd in linux-2.4.0-test2
Message-ID: <20000705225334.A6893@fred.muc.de>
References: <39627B27.24266363@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <39627B27.24266363@sun.com>; from ludovic fernandez on Wed, Jul 05, 2000 at 01:59:59AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ludovic fernandez <ludovic.fernandez@sun.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 05, 2000 at 01:59:59AM +0200, ludovic fernandez wrote:
> Hello guys,
> 
> I'd like to submit a patch against linux-2.4.0-test2 regarding
> the vm/kswapd. The patch is attached to this email. Sorry I don't
> have access to a web or ftp server where I can put it.

[...] 

Nice work. As a datapoint it runs fine on my UP machine with various loads
and feels ``snappy''.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
