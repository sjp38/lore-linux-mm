Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 98EF190023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 15:18:06 -0400 (EDT)
Date: Fri, 24 Jun 2011 15:17:57 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
Message-ID: <20110624191757.GA3805@infradead.org>
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com>
 <m2liwrul1f.fsf@firstfloor.org>
 <BANLkTimLsnyX6kr6B7uR2SPoHCzuvLzsoQ@mail.gmail.com>
 <20110624191334.GA31183@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110624191334.GA31183@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Lutomirski <luto@mit.edu>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org

On Fri, Jun 24, 2011 at 09:13:34PM +0200, Andi Kleen wrote:
> Maybe the graphics driver could be still nicer the VM and perhaps
> be more aggressive in the callback?

Or just fix the nasty bugs in there, e.g. apply

[PATCH] i915: slab shrinker have to return -1 if it can't shrink any objects

which was sent to lkml today.  Also the first three patches from Dave
Chinners per-sb shrinker series, which fix two bugs in the core shrinker
code, and add tracing to it should help a lot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
