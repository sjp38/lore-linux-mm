Message-ID: <420240F8.6020308@sgi.com>
Date: Thu, 03 Feb 2005 09:19:20 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: migration cache, updated
References: <41FE79EF.8040204@sgi.com>	<20050131184422.GD15694@logos.cnet>	<42014605.4060707@sgi.com> <20050203.115911.119293038.taka@valinux.co.jp>
In-Reply-To: <20050203.115911.119293038.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:
> Hi Ray,
> 
> 
>>>>(This message comes from ia64_do_page_fault() and appears to because
>>>>handle_mm_fault() returned FAULT_OOM....)
>>>>
>>>>I haven't looked into this further, but was wondering if perhaps one of
>>>>you would understand why the migrate cache patch would fail in this way?
>>>
>>>
>>>I can't think of anything right now - probably do_wp_page() is returning FAULT_OOM,
>>>can you confirm that?
>>>
>>
>>No, it doesn't appear to be do_wp_page().  It looks like get_swap_page() 
>>returns FAULT_OOM followed by get_user_pages() returning FAULT_OOM.
>>For the page that causes the VM to kill the process, there is no return
>>from get_user_pages() that returns FAULT_OOM.  Not sure yet what is going
>>on here.
> 
> 
> The current implementation requires swap devices to migrate pages.
> Have you added any swap devices?
> 
> This restriction will be solved with the migration cache Marcelo
> is working on.
> 
> Thanks,
> Hirokazu Takahashi.
> 
> 
I'm running with the migration cache patch applied as well.  This is a
requirement for the project I am working on as the customer doesn't want
to swap out pages just to migrated them.

If I take out the migration cache patch, this "VM: killing ..." problem
goes away.   So it has something to do specifically with the migration
cache code.

-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
