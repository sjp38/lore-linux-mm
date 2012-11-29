Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 732026B0078
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 23:22:10 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so13050179qcq.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 20:22:09 -0800 (PST)
Date: Wed, 28 Nov 2012 20:22:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
In-Reply-To: <20121129024446.GY6434@dastard>
Message-ID: <alpine.LNX.2.00.1211282011120.972@eggly.anvils>
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils> <20121129024446.GY6434@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Jeff liu <jeff.liu@oracle.com>, Jim Meyering <jim@meyering.net>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 29 Nov 2012, Dave Chinner wrote:
> On Wed, Nov 28, 2012 at 05:22:03PM -0800, Hugh Dickins wrote:
> > Revert 3.5's f21f8062201f ("tmpfs: revert SEEK_DATA and SEEK_HOLE")
> > to reinstate 4fb5ef089b28 ("tmpfs: support SEEK_DATA and SEEK_HOLE"),
> > with the intervening additional arg to generic_file_llseek_size().
> > 
> > In 3.8, ext4 is expected to join btrfs, ocfs2 and xfs with proper
> > SEEK_DATA and SEEK_HOLE support; and a good case has now been made
> > for it on tmpfs, so let's join the party.
> > 
> > It's quite easy for tmpfs to scan the radix_tree to support llseek's new
> > SEEK_DATA and SEEK_HOLE options: so add them while the minutiae are still
> > on my mind (in particular, the !PageUptodate-ness of pages fallocated but
> > still unwritten).
> > 
> > [akpm@linux-foundation.org: fix warning with CONFIG_TMPFS=n]
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > ---
> 
> Does it pass the seek hole/data tests (285, 286) in xfstests?

It did before and ... [install this, install that, install tother]
... yes, it still passes those tests - using Boris Ranto's patch
extending xfstests to include tmpfs.

Though I'd have even more confidence if they gave a little pat on
the back for doing better than the no-op default, which also passes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
