Date: Tue, 9 Nov 2004 21:08:11 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Use MPOL_INTERLEAVE for tmpfs files
In-Reply-To: <463220000.1100030992@flay>
Message-ID: <Pine.LNX.4.44.0411092056090.5291-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Brent Casavant <bcasavan@sgi.com>, Andi Kleen <ak@suse.de>, "Adam J. Richter" <adam@yggdrasil.com>, colpatch@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2004, Martin J. Bligh wrote:
>  
> > I'm irritated to realize that we can't change the default for SysV
> > shared memory or /dev/zero this way, because that mount is internal.
> 
> Boggle. shmem I can perfectly understand, and have been intending to
> change for a while. But why /dev/zero ? Presumably you'd always want
> that local?

I was meaning the mmap shared writable of /dev/zero, to get memory
shared between parent and child and descendants, a restricted form
of shared memory.  I was thinking of them running on different cpus,
you're suggesting they'd at least be on the same node.  I dare say,
I don't know.  I'm not desperate to be able to set some other mpol
default for all of them (and each object can be set in the established
way), just would have been happier if the possibility of doing so came
for free with the mount option work.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
