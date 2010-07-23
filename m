Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D24D16B02A5
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 10:04:54 -0400 (EDT)
Date: Fri, 23 Jul 2010 10:04:40 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V3 0/8] Cleancache: overview
Message-ID: <20100723140440.GA12423@infradead.org>
References: <20100621231809.GA11111@ca-server1.us.oracle.com4C49468B.40307@vflare.org>
 <840b32ff-a303-468e-9d4e-30fc92f629f8@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <840b32ff-a303-468e-9d4e-30fc92f629f8@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: ngupta@vflare.org, Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 06:58:03AM -0700, Dan Magenheimer wrote:
> CHRISTOPH AND ANDREW, if you disagree and your concerns have
> not been resolved, please speak up.

Anything that need modification of a normal non-shared fs is utterly
broken and you'll get a clear NAK, so the propsal before is a good
one.  There's a couple more issues like the still weird prototypes,
e.g. and i_ino might not be enoug to uniquely identify an inode
on serveral filesystems that use 64-bit inode inode numbers on 32-bit
systems.  Also making the ops vector global is just a bad idea.
There is nothing making this sort of caching inherently global.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
