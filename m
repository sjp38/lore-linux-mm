Date: Sat, 7 Jul 2007 12:45:35 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: vm/fs meetup details
Message-ID: <20070707104534.GA5686@lazybastard.org>
References: <20070705040138.GG32240@wotan.suse.de> <468D303E.4040902@redhat.com> <20070706020042.GD14215@wotan.suse.de> <Pine.LNX.4.64.0707061339100.24812@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.64.0707061339100.24812@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Zach Brown <zach.brown@oracle.com>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Chris Mason <chris.mason@oracle.com>, David Chinner <dgc@sgi.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Joern Engel <joern@logfs.org>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 July 2007 13:40:03 -0700, Christoph Lameter wrote:
> 
> An interesting topic is certainly
> 
> 1. Large buffer support
> 
> 2. icache/dentry/buffer_head defragmentation.

Oh certainly!  I should dust off my dcache_static patch.  Some dentries
are hands-off for the shrinker, basically mountpoints and tmpfs.  The
patch moves those to a seperate slab cache.

JA?rn

-- 
Data dominates. If you've chosen the right data structures and organized
things well, the algorithms will almost always be self-evident. Data
structures, not algorithms, are central to programming.
-- Rob Pike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
