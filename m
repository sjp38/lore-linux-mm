Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] using writepage to start io
Date: Tue, 7 Aug 2001 17:52:28 +0200
References: <Pine.GSO.4.21.0108070928250.18565-100000@weyl.math.psu.edu>
In-Reply-To: <Pine.GSO.4.21.0108070928250.18565-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Message-Id: <01080717522808.02365@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Anton Altaparmakov <aia21@cam.ac.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 August 2001 15:31, Alexander Viro wrote:
> On Tue, 7 Aug 2001, Daniel Phillips wrote:
> > One thread per block device; flushes across mounts on the same
> > device are serialized.  This model works well for fs->device graphs
> > that are strict trees.  For a non-strict tree (acyclic graph) its
> > not clear what to do, but you could argue that such a configuration
> > is stupid, so any kind of punt would do.
>
> Except that you can have a part of fs structures on a separate device.
> Journal, for one thing. Now think of two disks, both partitioned. Two
> filesystems. Each has data on the first partition of its own disk.
> And journal on the second of another.

And you want the write scheduling to not interfere when both are
active?  Good luck.  I'd call this a dumb configuration from the
point of view of performance.

That said, the update daemon can just ignore the connection between
data and journal partitions and let the fs take case of that itself
if it needs to.  Ext3 doesn't need to, the usual kupdate rules are
good enough.

So the parallel/serial update strategy survives this case just fine,
however something tells me your fevered imagination is capable of
coming up with yet another bizarre configuration or two...

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
