Date: Fri, 25 Aug 2006 18:10:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: ZVC: Support NR_SLAB_RECLAIM
In-Reply-To: <20060825180739.5ade8934.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608251808350.11715@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608251500560.11154@schroedinger.engr.sgi.com>
 <20060825165659.0d8c03d4.akpm@osdl.org> <Pine.LNX.4.64.0608251728240.11715@schroedinger.engr.sgi.com>
 <20060825175517.b41f129d.akpm@osdl.org> <Pine.LNX.4.64.0608251756080.11715@schroedinger.engr.sgi.com>
 <20060825180739.5ade8934.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Aug 2006, Andrew Morton wrote:

> Do they have a URL?

I would have to research that but I am not aware of any. I would more 
think about these as a script collection. I am not too fond of those 
myself since I like my own scripts better. Mostly I grep through 
the /proc files.

> > Note that 2.6.18 with the ZVCs also changes /proc/meminfo. I tried to sync 
> > them up and make the names clearer.
> 
> Yes, I looked.  AFACIT the only changes are the addition of new things, and
> that's OK.  We've surely trained downstream people to be tolerant of that by
> now.

You need to change NFS_unstable in meminfo too. Will sent a patch if 
necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
