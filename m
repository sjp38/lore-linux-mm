From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
Date: Fri, 25 May 2007 23:01:00 +0200
References: <20070524172821.13933.80093.sendpatchset@localhost> <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com> <1180114648.5730.64.camel@localhost>
In-Reply-To: <1180114648.5730.64.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705252301.00722.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

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

But "you can set policy but we will randomly lose it later" is also
not very convincing, isn't it? 

I would like to only go forward if there are actually convincing
use cases for this.

The Tru64 compat argument doesn't seem too strong to me for this because
I'm sure there are lots of other incompatibilities too.

> And as for fixing the numa_maps behavior, hey, I didn't post the
> defective code.  I'm just pointing out that my patches happen to fix
> some existing suspect behavior along the way.  But, if some patch
> submittal standard exists that says one must fix all known outstanding
> bugs before submitting anything else [Andrew would probably support
> that ;-)], please point it out to me... and everyone else.  And, as I've
> said before, I see this patch set as one big fix to missing/broken
> behavior.  

In Linux the deal is usually kind of :- the more you care about general
code maintenance the more we care about your feature wishlists.
So fixing bugs is usually a good idea.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
