Date: Fri, 18 May 2007 14:04:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 08/10] shmem: inode defragmentation support
In-Reply-To: <Pine.LNX.4.61.0705182233120.9015@yvahk01.tjqt.qr>
Message-ID: <Pine.LNX.4.64.0705181403370.13256@schroedinger.engr.sgi.com>
References: <20070518181040.465335396@sgi.com> <20070518181120.477184338@sgi.com>
 <Pine.LNX.4.61.0705182233120.9015@yvahk01.tjqt.qr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, Jan Engelhardt wrote:

> Do we need *this*? (compare procfs)
> 
> I believe that shmfs's inodes remain "more" in memory than those of
> procfs. That is, procfs ones can find their way out (we can regenerate
> it), while shmfs/tmpfs/ramfs/etc. should not do that (we'd lose the
> file).

Ahh... Okay so shmem inodes are not defraggable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
