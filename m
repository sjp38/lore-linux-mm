Date: Tue, 9 Sep 2008 10:58:44 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Remove warning in compilation of ioremap
Message-ID: <20080909095844.GF9104@flint.arm.linux.org.uk>
References: <48C63E28.6060605@evidence.eu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48C63E28.6060605@evidence.eu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Claudio Scordino <claudio@evidence.eu.com>
Cc: linux-arm-kernel@lists.arm.linux.org.uk, linux-mm@kvack.org, Phil Blundell <philb@gnu.org>, "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 09, 2008 at 11:13:12AM +0200, Claudio Scordino wrote:
> When compiling Linux (latest kernel from Linus' git) on ARM, I noticed
> the following warning:
> 
> CC      arch/arm/mm/ioremap.o
> arch/arm/mm/ioremap.c: In function '__arm_ioremap_pfn':
> arch/arm/mm/ioremap.c:83: warning: control may reach end of non-void
> function 'remap_area_pte' being inlined
> 
> If you look at the code, the problem is in a path including a BUG().
> 
> AFAIK, on ARM the code following BUG() is never executed: it's a NULL
> pointer dereference, so the handler of pagefault eventually calls
> do_exit(). Therefore, we may want to remove the goto as shown in the
> patch in attachment.
> 
> It's obviously a minor issue. But I don't like having meaningless
> warnings during compilation: they just confuse output, and developers 
> may miss some important warning message...
> 
> The need for the goto exists only if BUG() can return. If it doesn't,
> we can safely remove it as shown in the patch.

NAK.  See patch 5211/2 in the patch system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
