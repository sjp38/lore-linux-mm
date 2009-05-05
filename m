Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BAD096B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 12:56:48 -0400 (EDT)
Date: Tue, 5 May 2009 11:47:14 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 2/3] mm: SLOB fix reclaim_state
Message-ID: <20090505164714.GJ31071@waste.org>
References: <20090505091343.706910164@suse.de> <20090505091434.456070042@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090505091434.456070042@suse.de>
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: penberg@cs.helsinki.fi, stable@kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 05, 2009 at 07:13:45PM +1000, npiggin@suse.de wrote:
> SLOB does not correctly account reclaim_state.reclaimed_slab, so it will
> break memory reclaim. Account it like SLAB does.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
