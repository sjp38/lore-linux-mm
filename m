Message-ID: <3C058875.1392B3AC@mandrakesoft.com>
Date: Wed, 28 Nov 2001 19:59:33 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: Status of sendfile() + HIGHMEM
References: <3C0577FF.3040209@zytor.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"H. Peter Anvin" wrote:
> 
> zeus.kernel.org is currently running with HIGHMEM turned off, since it
> crashed due to an unfortunate interaction between sendfile() and HIGHMEM
> -- this was using 2.4.10-ac4 or thereabouts.
> 
> The current zeus.kernel.org has 1 GB of RAM, however, it looks like we're
> going to get a 6 GB machine donated.  Clearly HIGHMEM is going to be
> necessary (still an x86 machine, unfortunately), and I wanted to ask if it
> was believed that these problems had been worked out...

Get a 64-bit machine and forget about doing >32bits on a 32-bit machine
:)

-- 
Jeff Garzik      | Only so many songs can be sung
Building 1024    | with two lips, two lungs, and one tongue.
MandrakeSoft     |         - nomeansno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
