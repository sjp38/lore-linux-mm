Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id F2F086B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 01:40:07 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1688042pbc.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 22:40:07 -0700 (PDT)
Date: Thu, 22 Mar 2012 14:39:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
Message-ID: <20120322053958.GA5278@barrios>
References: <20120321065140.13852.52315.stgit@zurg>
 <20120321100602.GA5522@barrios>
 <4F69D496.2040509@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F69D496.2040509@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

On Wed, Mar 21, 2012 at 05:16:06PM +0400, Konstantin Khlebnikov wrote:
> Minchan Kim wrote:
> >Hi Konstantin,
> >
> >It seems to be nice clean up to me and you are a volunteer we have been wanted
> >for a long time. Thanks!
> >I am one of people who really want to expand vm_flags to 64 bit but when KOSAKI
> >tried it, Linus said his concerning, I guess you already saw that.
> >
> >He want to tidy vm_flags's usage up rather than expanding it.
> >Without the discussion about that, just expanding vm_flags would make us use
> >it up easily so that we might need more space.
> 
> Strictly speaking, my pachset does not expands vm_flags, it just prepares to this.
> Anyway vm_flags_t looks better than hard-coded "unsigned long" and messy type-casts around it.

Indeed.

> 
> >
> >Readahead flags are good candidate to move into another space and arch-specific flags, I guess.
> >Another candidate I think of is THP flag. It's just for only anonymous vma now
> >(But I am not sure we have a plan to support it for file-backed pages in future)
> >so we can move it to anon_vma or somewhere.
> >I think other guys might find more somethings
> >
> >The point is that at least, we have to discuss about clean up current vm_flags's
> >use cases before expanding it unconditionally.
> 
> Seems like we can easily remove VM_EXECUTABLE
> (count in mm->num_exe_file_vmas amount of vmas with vma->vm_file == mm->exe_file
> instead of vmas with VM_EXECUTABLE bit)
> 
> And probably VM_CAN_NONLINEAR...

I think we can also unify VM_MAPPED_COPY(nommu) and VM_SAO(powerpc) with one VM_ARCH_1
Okay. After this series is merged, let's try to remove flags we can do. Then, other guys
might suggest another ideas.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
