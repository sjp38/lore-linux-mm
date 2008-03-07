Date: Fri, 7 Mar 2008 19:32:55 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [8/13] Enable the mask allocator for x86
Message-ID: <20080307183255.GB14779@uranus.ravnborg.org>
References: <200803071007.493903088@firstfloor.org> <20080307090718.A609E1B419C@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307090718.A609E1B419C@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 10:07:18AM +0100, Andi Kleen wrote:
> 
> - Disable old ZONE_DMA
> No fixed size ZONE_DMA now anymore. All existing users of __GFP_DMA rely 
> on the compat call to the maskable allocator in alloc/free_pages
> - Call maskable allocator initialization functions at boot
> - Add TRAD_DMA_MASK for the compat functions 

I see TRAD_DMA_MASK used by patch 6 and patch 7, but only here
in this later patch it is defined.
Looks like we have build breakage - but I have not checked it.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
