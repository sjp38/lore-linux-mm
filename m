Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 373FB6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:41:23 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <43348bbd-649d-47db-8edd-c5cb08187f19@default>
Date: Tue, 24 Aug 2010 13:42:55 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: cleancache followup from LSF10/MM summit
References: <66336896-4396-458f-b8a5-51282a925816@default
 20100824142718.GA24164@balbir.in.ibm.com>
In-Reply-To: <20100824142718.GA24164@balbir.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <bharrosh@panasas.com>, ngupta@vflare.org, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, Andreas Dilger <andreas.dilger@oracle.com>, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, npiggin@kernel.dk
List-ID: <linux-mm.kvack.org>

Hi Balbir --

Thanks for reviewing!

> 1. Can't this be done at the MM layer - why the filesystem hooks? Is
> it to enable faster block devices in the reclaim hierarchy?

This is explained in FAQ #2 in: http://lkml.org/lkml/2010/6/21/411
If I misunderstood your question or the FAQ doesn't answer it, please
let me know.

> 2. I don't see a mention of slabcache in your approach, reclaim free
> pages or freeing potentially free slab pages.

Cleancache works on clean mapped pages that are reclaimed ("evicted")
due to (guest) memory pressure but later would result in a refault.
The decision of what pages to reclaim are left entirely to the
(guest) kernel, and the "backend" (zcache or Xen tmem) dynamically
decides how many clean evicted pages to retain based on dynamic
factors that are unknowable to the (guest) kernel (such as compression
ratios for zcache and available fallow memory for Xen tmem).

I'm not sure I see how this could apply to slabcache (and
I couldn't find anything in your OLS paper that refers to it),
but if you have some ideas, let's discuss (offlist?).

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
