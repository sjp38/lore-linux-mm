Date: Tue, 2 Nov 2004 10:13:06 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Use MPOL_INTERLEAVE for tmpfs files
Message-ID: <20041102091306.GC21619@wotan.suse.de>
References: <Pine.SGI.4.58.0411011901540.77038@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.58.0411011901540.77038@kzerza.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

> And now, for your viewing pleasure...

Patch is fine except that I would add a sysctl to enable/disable this.

I can see that some people would like to not have interleave policy
(e.g. when you use tmpfs as a large memory extender on 32bit NUMA
then you probably want local affinity) 

Best if you name it /proc/sys/vm/numa-tmpfs-rr

Default can be set to one for now.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
