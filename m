Date: Fri, 25 May 2007 12:10:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
In-Reply-To: <1180114648.5730.64.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705251156460.7281@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
 <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
 <1180104952.5730.28.camel@localhost>  <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
  <1180109165.5730.32.camel@localhost>  <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
 <1180114648.5730.64.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007, Lee Schermerhorn wrote:

> I knew that!  There is no existing practice.  However, I think it is in
> our interests to ease the migration of applications to Linux.  And,
> again, [trying to choose words carefully], I see this as a
> defect/oversight in the API.  I mean, why provide mbind() at all, and
> then say, "Oh, by the way, this only works for anonymous memory, SysV
> shared memory and private file mappings. You can't use this if you
> mmap() a file shared.  For that you have to twiddle your task policy,
> fault in and lock down the pages to make sure they don't get paged out,
> because, if they do, and you've changed the task policy to place some
> other mapped file that doesn't obey mbind(), the kernel doesn't remember
> where you placed them.  Oh, and for those private mappings--be sure to
> write to each page in the range because if you just read, the kernel
> will ignore your vma policy."
> 
> Come on!  

Well if this patch would simplify things then I would agree but it 
introduces new cornercases.

The current scheme is logical if you consider the pagecache as something 
separate. It is after all already controlled via the memory spreading flag 
in cpusets. There is already limited control by the process.

Also allowing vma based memory policies to control shared mapping is 
problematic because they are shared. Concurrent processes may set 
different policies. This would make sense if the policy could be set at a 
filesystem level.

> And as for fixing the numa_maps behavior, hey, I didn't post the
> defective code.  I'm just pointing out that my patches happen to fix
> some existing suspect behavior along the way.  But, if some patch
> submittal standard exists that says one must fix all known outstanding
> bugs before submitting anything else [Andrew would probably support
> that ;-)], please point it out to me... and everyone else.  And, as I've
> said before, I see this patch set as one big fix to missing/broken
> behavior.  

I still have not found a bug in there....

Convention is that fixes precede enhancements in a patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
