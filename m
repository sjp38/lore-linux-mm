Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
	 <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
	 <1180104952.5730.28.camel@localhost>
	 <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
	 <1180109165.5730.32.camel@localhost>
	 <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 25 May 2007 13:37:28 -0400
Message-Id: <1180114648.5730.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-25 at 09:24 -0700, Christoph Lameter wrote:
> On Fri, 25 May 2007, Lee Schermerhorn wrote:
> 
> > True, but shared, mmap'ed file policy does need to be file based, and
> > that is my objective.  I merely point out that we can easily add the
> > page cache policy as the fall back when a file has no explicit policy.
> 
> The problem is that you have not given sufficient reason for the 
> modifications. Tru64 compatibility is not a valid reason.

I knew that!  There is no existing practice.  However, I think it is in
our interests to ease the migration of applications to Linux.  And,
again, [trying to choose words carefully], I see this as a
defect/oversight in the API.  I mean, why provide mbind() at all, and
then say, "Oh, by the way, this only works for anonymous memory, SysV
shared memory and private file mappings. You can't use this if you
mmap() a file shared.  For that you have to twiddle your task policy,
fault in and lock down the pages to make sure they don't get paged out,
because, if they do, and you've changed the task policy to place some
other mapped file that doesn't obey mbind(), the kernel doesn't remember
where you placed them.  Oh, and for those private mappings--be sure to
write to each page in the range because if you just read, the kernel
will ignore your vma policy."

Come on!  

> 
> > > Could you separate out a patch that fixes these issues?
> > 
> > Could do, but does that improve the chances for acceptance of this patch
> > set?  If the patch set is accepted, with whatever corrections might be
> > required, we get the numa_maps fix.  So, I'm not currently motivated to
> > post a separate patch.
> 
> The patchset as is is not acceptable since it does not follow the 
> standards. The fixes should come first. So you have to do this anyways to 
> get the patchset accepted.

Which standards are we talking about?  I'll happily fix any coding
standard violations.  Is there something wrong with the format of the
patches?  Please tell me, so I can fix them...

And as for fixing the numa_maps behavior, hey, I didn't post the
defective code.  I'm just pointing out that my patches happen to fix
some existing suspect behavior along the way.  But, if some patch
submittal standard exists that says one must fix all known outstanding
bugs before submitting anything else [Andrew would probably support
that ;-)], please point it out to me... and everyone else.  And, as I've
said before, I see this patch set as one big fix to missing/broken
behavior.  

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
