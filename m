Message-ID: <410B13E5.9080005@sgi.com>
Date: Fri, 30 Jul 2004 22:37:09 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
References: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>	<Pine.SGI.4.58.0407301633051.36748@kzerza.americas.sgi.com> <20040730163443.37f9b309.pj@sgi.com>
In-Reply-To: <20040730163443.37f9b309.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Brent Casavant <bcasavan@sgi.com>, hugh@veritas.com, wli@holomorphy.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Perhaps, but then you still have one processor doing the zeroing and setup for 
all of those pages, and that can be a signficiant serial bottleneck.

Paul Jackson wrote:
> Brent wrote:
> 
>>Having a single CPU fault in all the pages will generally
>>cause all pages to reside on a single NUMA node.
> 
> 
> Couldn't one use Andi Kleen's numa mbind() to layout the
> memory across the desired nodes, before faulting it in?
> 

-- 
Best Regards,
Ray
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
