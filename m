Date: Thu, 03 Feb 2005 11:59:11 +0900 (JST)
Message-Id: <20050203.115911.119293038.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <42014605.4060707@sgi.com>
References: <41FE79EF.8040204@sgi.com>
	<20050131184422.GD15694@logos.cnet>
	<42014605.4060707@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi Ray,

> >>(This message comes from ia64_do_page_fault() and appears to because
> >>handle_mm_fault() returned FAULT_OOM....)
> >>
> >>I haven't looked into this further, but was wondering if perhaps one of
> >>you would understand why the migrate cache patch would fail in this way?
> > 
> > 
> > I can't think of anything right now - probably do_wp_page() is returning FAULT_OOM,
> > can you confirm that?
> > 
> No, it doesn't appear to be do_wp_page().  It looks like get_swap_page() 
> returns FAULT_OOM followed by get_user_pages() returning FAULT_OOM.
> For the page that causes the VM to kill the process, there is no return
> from get_user_pages() that returns FAULT_OOM.  Not sure yet what is going
> on here.

The current implementation requires swap devices to migrate pages.
Have you added any swap devices?

This restriction will be solved with the migration cache Marcelo
is working on.

Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
