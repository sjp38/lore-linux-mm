Date: Fri, 04 Feb 2005 16:32:48 +0900 (JST)
Message-Id: <20050204.163248.41633006.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <420240F8.6020308@sgi.com>
References: <42014605.4060707@sgi.com>
	<20050203.115911.119293038.taka@valinux.co.jp>
	<420240F8.6020308@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi Ray,

I realized the situation.

> >>>>(This message comes from ia64_do_page_fault() and appears to because
> >>>>handle_mm_fault() returned FAULT_OOM....)
> >>>>
> >>>>I haven't looked into this further, but was wondering if perhaps one of
> >>>>you would understand why the migrate cache patch would fail in this way?
> >>>
> >>>
> >>>I can't think of anything right now - probably do_wp_page() is returning FAULT_OOM,
> >>>can you confirm that?
> >>>
> >>
> >>No, it doesn't appear to be do_wp_page().  It looks like get_swap_page() 
> >>returns FAULT_OOM followed by get_user_pages() returning FAULT_OOM.
> >>For the page that causes the VM to kill the process, there is no return
> >>from get_user_pages() that returns FAULT_OOM.  Not sure yet what is going
> >>on here.
> > 
> > 
> > The current implementation requires swap devices to migrate pages.
> > Have you added any swap devices?
> > 
> > This restriction will be solved with the migration cache Marcelo
> > is working on.
> > 
> > Thanks,
> > Hirokazu Takahashi.
> > 
> > 
> I'm running with the migration cache patch applied as well.  This is a
> requirement for the project I am working on as the customer doesn't want
> to swap out pages just to migrated them.

I see.

> If I take out the migration cache patch, this "VM: killing ..." problem
> goes away.   So it has something to do specifically with the migration
> cache code.

I've never seen the message though the migration cache code may have
some bugs. May I ask you some questions about it?

 - Which version of kernel did you use for it?
 - Which migration cache code did you choose?
 - How many nodes, CPUs and memory does your box have?
 - What kind of applications were running on your box?
 - How often did this happened?
 - Did this message appear right after starting the migration?
   Or it appeared some short while later?
 - How the target pages to be migrated were selected?
 - How did you kick memory migration started?
 - Please show me /proc/meminfo when the problem happened.
 - Is it possible to make the same problem on my machine?

And, would you please make your project proceed without the
migration cache code for a while?

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
