Date: Fri, 13 Jun 2003 12:57:30 -0500
From: Brandon Low <lostlogic@gentoo.org>
Subject: Re: 2.5.70-mm9
Message-ID: <20030613175730.GD24578@lostlogicx.com>
References: <20030613013337.1a6789d9.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030613013337.1a6789d9.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I tried to compile this drivre and got a ton of undefined references to
psmouse_command ... haven't looked at the code yet, but I'd guess it
only works when builtin, not as a module?  Need an export symbol
somewhere?

--Brandon Low
Gentoo Dork/Dev :)

On Fri, 06/13/03 at 01:33:37 -0700, Andrew Morton wrote:
> +synaptics.patch
> +synaptics-cleanup.patch
> 
>  Synaptics driver (one flavour thereof)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
