Date: Thu, 5 Feb 2004 10:00:04 +0000
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: 2.6.2-mm1 aka "Geriatric Wombat"
Message-ID: <20040205100004.A5426@flint.arm.linux.org.uk>
References: <20040205014405.5a2cf529.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040205014405.5a2cf529.akpm@osdl.org>; from akpm@osdl.org on Thu, Feb 05, 2004 at 01:44:05AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 05, 2004 at 01:44:05AM -0800, Andrew Morton wrote:
>  bk-netdev.patch

Does this include the changes to all those PCMCIA net drivers which
Jeff has had for a while from me?

I'd like to get those patches into mainline so I can close bugme bug
1711, but I think Jeff's waiting for responses from the individual
net driver maintainers first. ;(

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
