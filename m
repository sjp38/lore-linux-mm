Message-ID: <42014605.4060707@sgi.com>
Date: Wed, 02 Feb 2005 15:28:37 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: migration cache, updated
References: <20041123121447.GE4524@logos.cnet> <20041124.192156.73388074.taka@valinux.co.jp> <20041201202101.GB5459@dmt.cyclades> <20041208.222307.64517559.taka@valinux.co.jp> <20050117095955.GC18785@logos.cnet> <41FE79EF.8040204@sgi.com> <20050131184422.GD15694@logos.cnet>
In-Reply-To: <20050131184422.GD15694@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> 
>>
>>(This message comes from ia64_do_page_fault() and appears to because
>>handle_mm_fault() returned FAULT_OOM....)
>>
>>I haven't looked into this further, but was wondering if perhaps one of
>>you would understand why the migrate cache patch would fail in this way?
> 
> 
> I can't think of anything right now - probably do_wp_page() is returning FAULT_OOM,
> can you confirm that?
> 
No, it doesn't appear to be do_wp_page().  It looks like get_swap_page() 
returns FAULT_OOM followed by get_user_pages() returning FAULT_OOM.
For the page that causes the VM to kill the process, there is no return
from get_user_pages() that returns FAULT_OOM.  Not sure yet what is going
on here.

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
