Subject: Re: [PATCH 2/2] move slab pages to the lru, for 2.5.27
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <Pine.LNX.4.44.0207210245080.6770-100000@loke.as.arizona.edu>
References: <Pine.LNX.4.44.0207210245080.6770-100000@loke.as.arizona.edu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Jul 2002 12:54:28 -0600
Message-Id: <1027364068.12588.26.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Cole <scole@lanl.gov>
List-ID: <linux-mm.kvack.org>

On Sun, 2002-07-21 at 05:24, Craig Kulesa wrote:
> 
> 
> This is an update for the 2.5 port of Ed Tomlinson's patch to move slab
> pages onto the lru for page aging, atop 2.5.27 and the full rmap patch.  
> It is aimed at being a fairer, self-tuning way to target and evict slab
> pages.
> 
> Previous description:  
> 	http://mail.nl.linux.org/linux-mm/2002-07/msg00216.html
> Patch URL:
> 	http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/2.5.27/
> 

While trying to boot 2.5.27-rmap-slablru, I got this early in the boot:

Kernel panic: Failed to create pte-chain mempool!
In idle task - not syncing

No other information was available.
I had previously booted and run 2.5.27 and 2.5.27-rmap.  I had to unset
CONFIG_QUOTA to get 2.5.27-rmap-slablru to compile.
I first applied the 2.5.27-rmap-1-rmap13b patch for 2.5.27-rmap, and
then applied the 2.5.27-rmap-2-slablru patch for 2.5.27-rmap-slablru.

The test machine is a dual p3 valinux 2231. Some options from .config:

[steven@spc9 linux-2.5.27-ck]$ grep HIGH .config
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
# CONFIG_HIGHPTE is not set
CONFIG_HIGHMEM=y

Steven




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
