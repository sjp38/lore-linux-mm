Date: Tue, 7 Aug 2001 09:31:07 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [RFC] using writepage to start io
In-Reply-To: <01080715292606.02365@starship>
Message-ID: <Pine.GSO.4.21.0108070928250.18565-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Anton Altaparmakov <aia21@cam.ac.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 7 Aug 2001, Daniel Phillips wrote:

> One thread per block device; flushes across mounts on the same device
> are serialized.  This model works well for fs->device graphs that are
> strict trees.  For a non-strict tree (acyclic graph) its not clear
> what to do, but you could argue that such a configuration is stupid,
> so any kind of punt would do.

Except that you can have a part of fs structures on a separate device.
Journal, for one thing. Now think of two disks, both partitioned. Two
filesystems. Each has data on the first partition of its own disk.
And journal on the second of another.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
