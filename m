Date: Sun, 21 Jul 2002 14:31:31 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 2/2] move slab pages to the lru, for 2.5.27
Message-ID: <20020721213131.GA919@holomorphy.com>
References: <Pine.LNX.4.44.0207210245080.6770-100000@loke.as.arizona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0207210245080.6770-100000@loke.as.arizona.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2002 at 04:24:55AM -0700, Craig Kulesa wrote:
> This is an update for the 2.5 port of Ed Tomlinson's patch to move slab
> pages onto the lru for page aging, atop 2.5.27 and the full rmap patch.  
> It is aimed at being a fairer, self-tuning way to target and evict slab
> pages.

In combination with the pte_chain in slab patch, this should at long last
enable reclamation of unused pte_chains after surges in demand. Can you
test this to verify that reclamation is actually done? (I'm embroiled in
a long debugging session at the moment.)


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
