Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C5EC36B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 20:28:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n330TAT0003726
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 09:29:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E63B45DE55
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 09:29:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F11045DD79
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 09:29:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BB391DB8038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 09:29:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C39BA1DB803E
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 09:29:09 +0900 (JST)
Date: Fri, 3 Apr 2009 09:27:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] don't show pgoff of vma if vma is pure ANON (was
 Re: mmotm 2009-01-12-16-53 uploaded)
Message-Id: <20090403092743.079f035b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090402131816.54724d4e.akpm@linux-foundation.org>
References: <200901130053.n0D0rhev023334@imap1.linux-foundation.org>
	<20090113181317.48e910af.kamezawa.hiroyu@jp.fujitsu.com>
	<496CC9D8.6040909@google.com>
	<20090114162245.923c4caf.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0901141349410.5465@blonde.anvils>
	<20090115114312.e42a0dba.kamezawa.hiroyu@jp.fujitsu.com>
	<20090402131816.54724d4e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hugh@veritas.com, mikew@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, yinghan@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 2 Apr 2009 13:18:16 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 15 Jan 2009 11:43:12 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 14 Jan 2009 14:08:35 +0000 (GMT)
> > Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > > On Wed, 14 Jan 2009, KAMEZAWA Hiroyuki wrote:
> > > > Hmm, is this brutal ?
> > > > 
> > > > ==
> > > > Recently, it's argued that what proc/pid/maps shows is ugly when a
> > > > 32bit binary runs on 64bit host.
> > > > 
> > > > /proc/pid/maps outputs vma's pgoff member but vma->pgoff is of no use
> > > > information is the vma is for ANON.
> > > > By this patch, /proc/pid/maps shows just 0 if no file backing store.
> > > > 
> > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > ---
> > > 
> > > Brutal, but sensible enough: revert to how things looked before
> > > we ever starting putting vm_pgoff to work on anonymous areas.
> > > 
> > > I slightly regret losing that visible clue to whether an anonymous
> > > vma has ever been mremap moved.  But have I ever actually used that
> > > info?  No, never.
> > > 
> > > I presume you test !vma->vm_file so the lines fit in, fair enough.
> > > But I think you'll find checkpatch.pl protests at "(!vma->vm_file)?"
> > > 
> > > I dislike its decisions on the punctuation of the ternary operator
> > > - perhaps even more than Andrew dislikes the operator itself!
> > > Do we write a space before a question mark? no: nor before a colon;
> > > but I also dislike getting into checkpatch.pl arguments!
> > > 
> > > While you're there, I'd also be inclined to make task_nommu.c
> > > use the same loff_t cast as task_mmu.c is using.
> > > 
> > Ok, I'll try to update to reasonable style.
> > 
> 
> afaik this update never happened?
> 
Ouch, sorry..could you wait ? I'll do soon....

-Kame

> Here's what I have at present:
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Recently, it's argued that what proc/pid/maps shows is ugly when a 32bit
> binary runs on 64bit host.
> 
> /proc/pid/maps outputs vma's pgoff member but vma->pgoff is of no use
> information is the vma is for ANON.  With this patch, /proc/pid/maps shows
> just 0 if no file backing store.
> 
> [akpm@linux-foundation.org: coding-style fixes]
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mike Waychison <mikew@google.com>
> Reported-by: Ying Han <yinghan@google.com>
> Cc: Hugh Dickins <hugh@veritas.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/proc/task_mmu.c   |    3 ++-
>  fs/proc/task_nommu.c |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff -puN fs/proc/task_mmu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas fs/proc/task_mmu.c
> --- a/fs/proc/task_mmu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas
> +++ a/fs/proc/task_mmu.c
> @@ -220,7 +220,8 @@ static void show_map_vma(struct seq_file
>  			flags & VM_WRITE ? 'w' : '-',
>  			flags & VM_EXEC ? 'x' : '-',
>  			flags & VM_MAYSHARE ? 's' : 'p',
> -			((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
> +			(!vma->vm_file) ? 0 :
> +				((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
>  			MAJOR(dev), MINOR(dev), ino, &len);
>  
>  	/*
> diff -puN fs/proc/task_nommu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas fs/proc/task_nommu.c
> --- a/fs/proc/task_nommu.c~proc-pid-maps-dont-show-pgoff-of-pure-anon-vmas
> +++ a/fs/proc/task_nommu.c
> @@ -143,7 +143,8 @@ static int nommu_vma_show(struct seq_fil
>  		   flags & VM_WRITE ? 'w' : '-',
>  		   flags & VM_EXEC ? 'x' : '-',
>  		   flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
> -		   (unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
> +		   (!vma->vm_file) ? 0 :
> +			(unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
>  		   MAJOR(dev), MINOR(dev), ino, &len);
>  
>  	if (file) {
> _
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
