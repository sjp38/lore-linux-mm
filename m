Subject: Re: [PATCH] get rid of vm_private_data and win posix shm
References: <qwwd7rrgeen.fsf@sap.com> <199912281914.LAA02201@penguin.transmeta.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 28 Dec 1999 21:48:24 +0100
In-Reply-To: Linus Torvalds's message of "Tue, 28 Dec 1999 11:14:36 -0800"
Message-ID: <qwwso0mg5bb.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-MM@kvack.org, Alexander Viro <viro@math.psu.edu>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> In article <qwwd7rrgeen.fsf@sap.com>,
> Christoph Rohland  <hans-christoph.rohland@sap.com> wrote:
> >
> >I implemented posix shm with its own namespace by extending filp_open
> >and do_unlink by an additional parameter for the root inode.
> 
> Beautiful patch _except_ for this case. I'm really pleased with how well
> the POSIX shm code seems to integrate into the FS and VM layers, and
> that makes me happy.
> 
> The one imbalance you added makes me cringe, though.  I think we should
> just export it as a real filesystem, and mount it in a standard
> location.  Nothing clever, just come up with a new location that is
> fixed and acceptable to all, kind of like /proc is now. 

O.K. After your and Alans objections I probably have to get rid of my
separate namespace ;-(

How do I do the SYSV shm stuff then? On creation I could grab the
first superblock and create the object there. But on removal I rely on
the fs unlink function through do_unlink. How do I get the right path
for the plain unlink call? You do not propose to code the location
into the kernel, don't you?

Any advice welcome
                        Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
