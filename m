Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73F006B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 10:00:15 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <840b32ff-a303-468e-9d4e-30fc92f629f8@default>
Date: Fri, 23 Jul 2010 06:58:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111@ca-server1.us.oracle.com
 4C49468B.40307@vflare.org>
In-Reply-To: <4C49468B.40307@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org, Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

> Since zcache is now one of its use cases, I think the major
> objection that remains against cleancache is its intrusiveness
> -- in particular, need to change individual filesystems (even
> though one liners). Changes below should help avoid these
> per-fs changes and make it more self contained.

Hi Nitin --

I think my reply at http://lkml.org/lkml/2010/6/22/202 adequately
refutes the claim of intrusiveness (43 lines!).  And FAQ #2 near
the end of the original posting at http://lkml.org/lkml/2010/6/21/411
explains why the per-fs "opt-in" approach is sensible and necessary.

CHRISTOPH AND ANDREW, if you disagree and your concerns have
not been resolved, please speak up.

Further, the maintainers of the changed filesystems have acked
the very minor cleancache patches; and maintainers of other
filesystems are not affected unless they choose to opt-in,
whereas these other filesystems MAY be affected with your
suggested changes to the patches.

So I think it's just a matter of waiting for the Linux wheels
to turn for a patch that (however lightly) touches a number of
maintainers' code, though I would very much welcome any
input on anything I can do to make those wheels turn faster.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
