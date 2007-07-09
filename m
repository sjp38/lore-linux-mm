Message-ID: <46925A10.8090104@mbligh.org>
Date: Mon, 09 Jul 2007 08:53:52 -0700
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: vm/fs meetup details
References: <20070705040138.GG32240@wotan.suse.de> <468D303E.4040902@redhat.com> <20070706020042.GD14215@wotan.suse.de> <Pine.LNX.4.64.0707061339100.24812@schroedinger.engr.sgi.com> <20070707104534.GA5686@lazybastard.org> <20070708232938.GG12413810@sgi.com> <20070709002720.GA13081@lazybastard.org>
In-Reply-To: <20070709002720.GA13081@lazybastard.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?windows-1252?Q?J=F6rn_Engel?= <joern@logfs.org>
Cc: David Chinner <dgc@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Zach Brown <zach.brown@oracle.com>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Chris Mason <chris.mason@oracle.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jorn Engel wrote:
> On Mon, 9 July 2007 09:29:38 +1000, David Chinner wrote:
>> On Sat, Jul 07, 2007 at 12:45:35PM +0200, JA?A?rn Engel wrote:
>>> Oh certainly!  I should dust off my dcache_static patch.  Some dentries
>>> are hands-off for the shrinker, basically mountpoints and tmpfs.  The
>>> patch moves those to a seperate slab cache.
>> I doubt there's enough of those to make any difference - putting all
>> the directories into another slab did little to reduce fragmentation
>> (~18 months ago we tried that), so I don't think that this would help
>> at all...
> 
> Interesting.  I suspect that the de-facto random cache eviction has a
> bigger effect and overshadows everything else.  So the decisive step
> would be to nuke all dentries in a given slab.
> 
> It wouldn't surprise me if your patch did make a difference afterwards.
> With 32 dentries per slab, it doesn't take many pinned objects to pin
> most slabs.

What happened to the patches floating around to stick the dentries for
directories into a different cache? IIRC, they were somewhat problematic
because you don't know what the dentry is used for at allocate time,
but did that ever get fixed / worked around?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
