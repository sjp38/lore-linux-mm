Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
	16gb
From: keith <kmannth@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0408251448370.4332-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0408251448370.4332-100000@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1093460701.5677.1881.camel@knk>
Mime-Version: 1.0
Date: Wed, 25 Aug 2004 12:05:01 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2004-08-25 at 07:05, Hugh Dickins wrote:
> On Tue, 24 Aug 2004, keith wrote:
> > 
> > Ok I created an attachment in the bug for the slab/buddy/mem info.  
> > You can watch zone normal get exhausted :)
> > http://bugme.osdl.org/show_bug.cgi?id=3268
> 
> Thanks.  Yes, your lowmem is full of Slab, and that's entirely
> unsurprising since you have CONFIG_DEBUG_PAGEALLOC on: so every
> slab object needs a full 4096-byte page to itself (well, there
> are some exceptions, but that doesn't change the picture).
> 
> That's a _very_ distorting config option, and I think this means that
> your report is of no interest in itself - sorry.  But it does raise a
> valid question whether it can happen in real, non-debug life - thanks.

I turned CONFIG_DEBUG_PAGEALLOC off.  I ran into problems when I tried
building 60 kernel trees or so.  It is using about 10gb of tmpfs space. 
See http://bugme.osdl.org/attachment.cgi?id=3566&action=view for more
info.

The bug also contains the config file used.  
> 
> I'll do the arithmetic on that when I've more leisure: I expect the
> answer to be that it can happen, and I ought to adjust defaulting of
> maximum tmpfs inodes.

It looks like there should be a maximum number of inodes for tmpfs.
Because I didn't know how many inodes it is using but I gave it a large
playground to use (mount -t tmpfs -o size=15G,nr_inodes=10000k,mode=0700
tmpfs /mytmpfs)

Thanks,
  Keith Mannthey 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
