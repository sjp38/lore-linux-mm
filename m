Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
	16gb
From: keith <kmannth@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0408252104540.2664-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0408252104540.2664-100000@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1093470564.5677.1920.camel@knk>
Mime-Version: 1.0
Date: Wed, 25 Aug 2004 14:49:25 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2004-08-25 at 13:37, Hugh Dickins wrote:
> On Wed, 25 Aug 2004, keith wrote:
> > 
> > I turned CONFIG_DEBUG_PAGEALLOC off.
> 
> Good, thanks.
> 
> > I ran into problems when I tried
> > building 60 kernel trees or so.  It is using about 10gb of tmpfs space. 
> > See http://bugme.osdl.org/attachment.cgi?id=3566&action=view for more
> > info.
> 
> Okay, that's more to the point.
> 
> > It looks like there should be a maximum number of inodes for tmpfs.
> > Because I didn't know how many inodes it is using but I gave it a large
> > playground to use (mount -t tmpfs -o size=15G,nr_inodes=10000k,mode=0700
> > tmpfs /mytmpfs)
> 
> Well, by default it does give you a maximum number of inodes for tmpfs:
> which at 16GB of RAM (in 4KB pages: odd that that factors in, but I've
> no great urge to depart from existing defaults except where it's buggy)
> would give you 2M inodes.  But since each might roughly be expected to
> consume 1KB (a shmem_inode, a dentry, a longer name, a radix node) of
> low memory, we'd want 2GB of lowmem to support all those: too much.

I think there is a need for a hard upper limit to the number of inodes
tmpfs can use.  With this system I can have 32gb of memory and I also
have a 64gb(i386) system. tempfs sizes above 15=g are definitely
possible.  What about a 40gig tmpfs.... 
> 
> So, how well does the patch below work for you, if you leave nr_inodes
> to its default?  Carry on setting size=15G, that should be okay; but
> I don't think the kernel should stop you if you insist on setting
> nr_inodes to something unfortunate like 10M.  "df -i" will show
> how many inodes it's actually giving you by default.

I was wondering how to do that thanks. 
With the patch I only get 82294 inodes.  Hmmmm.... I don't have any
lowmem issues but I can't create too many files.  

Thanks,
  Keith Mannthey 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
