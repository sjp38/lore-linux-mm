Date: Fri, 06 Sep 2002 12:54:46 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Rough cut at shared page tables
Message-ID: <68690000.1031334886@baldur.austin.ibm.com>
In-Reply-To: <20020906174405.GU18800@holomorphy.com>
References: <61920000.1031332808@baldur.austin.ibm.com>
 <20020906174405.GU18800@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Friday, September 06, 2002 10:44:05 AM -0700 William Lee Irwin III
<wli@holomorphy.com> wrote:

> Hmm, do non-i386 arches need to be taught about read-only pmd's?

Way back when this idea first surfaced, ISTR it was stated that most
architectures support it in the same way as x86.

> AFAICT one significant source of trouble is that pmd's, once
> instantiated, are considered immutable until the process is torn down.
> Numerous VM codepaths drop all locks but a readlock on the mm->mmap_sem
> while holding a reference to a pmd and expect it to remain valid.
> 
> The same issue arises during pagetable reclaim and pmd-based large page
> manipulations.

Yeah, I think I've seen most of them, but I need to come up with a decent
locking strategy for it all, and haven't yet.
 
> The swap strategy is interesting. I had originally imagined that a
> reference object would be required. But I'm not sure quite how RSS
> accounting for processes affected by a swap operation happens here.

I think rss accounting is probably the main issue, and I have some ideas
around that, including keeping an rss count in the struct page of the pte
page.  It's something kicking around in my head I plan to put in code soon.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
