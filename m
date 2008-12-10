Subject: Re: Question:  mmotm-081207 - Should i_mmap_writable go negative?
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0812101312340.16066@blonde.anvils>
References: <1228855666.6379.84.camel@lts-notebook>
	 <Pine.LNX.4.64.0812101312340.16066@blonde.anvils>
Content-Type: text/plain
Date: Wed, 10 Dec 2008 10:48:46 -0500
Message-Id: <1228924126.6139.16.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-12-10 at 13:27 +0000, Hugh Dickins wrote:
> On Tue, 9 Dec 2008, Lee Schermerhorn wrote:
> > I've been trying to figure out how to determine when the last shared
> > mapping [vma with VM_SHARED] is removed from a mmap()ed file.  Looking
> > at the sources, it appears that vma->vm_file->f_mapping->i_mmap_writable
> > counts the number of vmas with VM_SHARED mapping the file.  However, in
> > 2.6.28-rc7-mmotm-081207, it appears that i_mmap_writable doesn't get
> > incremented when a task fork()s, and can go negative when the parent and
> > child both unmap the file.
> 
> Wow, that's what I call a good find!
> 
> > I recall that this used to work [as I expected] at one time.
> 
> Are you sure?  It looks to me to have been wrong ever since I added
> i_mmap_writable.  Not that I've tested yet at all.  Here's the patch
> I intend to send Linus a.s.a.p: but I do need to test it, and also
> extend the comment to say just what's been done wrong all this time.

Well, no, not sure.  A test that I had done at one time seemed to work
then.  I recently started testing this area again, and noticed
"unexpected behavior" which I tracked down to this, uh, feature.  I may
have been doing the mmap() after the fork before, while this time I
forked after mmap().  Anyway, I'll add in your patch at test with that.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
