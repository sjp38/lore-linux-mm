Date: Thu, 15 May 2003 11:40:41 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030515094041.GA1429@dualathlon.random>
References: <154080000.1052858685@baldur.austin.ibm.com> <20030513181018.4cbff906.akpm@digeo.com> <18240000.1052924530@baldur.austin.ibm.com> <20030514103421.197f177a.akpm@digeo.com> <82240000.1052934152@baldur.austin.ibm.com> <20030515004915.GR1429@dualathlon.random> <20030515013245.58bcaf8f.akpm@digeo.com> <20030515085519.GV1429@dualathlon.random> <20030515022000.0eb9db29.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030515022000.0eb9db29.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: dmccr@us.ibm.com, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, May 15, 2003 at 02:20:00AM -0700, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > and it's still racy
> 
> damn, and it just booted ;)
> 
> I'm just a little bit concerned over the ever-expanding inode.  Do you
> think the dual sequence numbers can be replaced by a single generation
> counter?

yes, I wrote it as a single counter first, but was unreadable and it had
more branches, so I added the other sequence number to make it cleaner.
I don't mind another 4 bytes, that cacheline should be hot anyways.

> I do think that we should push the revalidate operation over into the vm_ops. 
> That'll require an extra arg to ->nopage, but it has a spare one anyway (!).

not sure why you need a callback, the lowlevel if needed can serialize
using the same locking in the address space that vmtruncate uses. I
would wait a real case need before adding a callback.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
