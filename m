Date: Sat, 14 Jul 2001 12:11:50 +1200
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [PATCH] VM statistics code
Message-ID: <20010714121150.B6048@weta.f00f.org>
References: <Pine.LNX.4.21.0107131856470.3716-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0107131856470.3716-100000@freak.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 13, 2001 at 07:08:23PM -0300, Marcelo Tosatti wrote:

    With this data we are able to know more about what is really going
    on in the VM.

    +vm_pglaunder: nr of page_launder() calls 
    +vm_pglaunder_write: nr of times page_launder() started writting out data to free 
    +memory.
    +vm_refill_inactive_scan: nr of refill_inactive_scan() calls
    +vm_alloc_resched: nr of reschedule's in __alloc_pages() due to a memory shortage.
    +vm_kswapd_wakeup: nr of kswapd wakeup's 
    +vm_kreclaimd_wakeup: nr of kreclaimd wakeup's 
    +vm_kflushd_wakeup: nr of kflushd wakeup's 
    +
    +Per-zone statistics:
    +free shortage: per-zone free shortage
    +inactive shortage: per-zone inactive shortage
    +vm_launder_pgscan: number of pages scanned by page_launder
    +vm_pgclean: number of pages cleaned (moved to the inactive clean list) by page_launder
    +vm_pgskiplocked: number of locked pages skipped by page_launder
    +vm_pgskipdirty: number of dirty pages skipped by page_launder
    +vm_pglaundered: laundered pages by page_launder
    +vm_pgreact: pages reactivated in page_launder
    +vm_pgrescue: pages rescue in reclaim_page
    +vm_pgagescan: pages scanned by refill_inactive_scan()
    +vm_pgagedown: pages aged down by refill_inative_scan()
    +vm_pgageup: pages aged up by refill_inactive_scan()/try_to_swap_out()
    +vm_pgdeact: deactivated pages by deactivate_page
    +vm_pgdeactfail_age: nr of deactivation failures on refill_inactive_scan() 
    +due to >0 age
    +vm_pgdeactfail_ref: nr of deactivation failures on refill_inactive_scan()
    +due to zero aged pages with more users than the pagecache
    +vm_reclaimfail: failures of reclaim_page() (no freeable clean pages in the inactive
    +clean list for this zone)
    +vm_ptescan: nr of present ptes scanned by swap_out()
    +vm_pteunmap: nr of present ptes unmapped by swap_out()

Some of these seem very specialised and low-level.

Perhaps another /proc entry might be a better idea along with either a
different vmstat, or changes to vmstat such that it will behave as
always if not given a magic command line switch and/or this new /proc
entry isn't present?

Right now, much of what comes form vmstat vaguley resembles other OSs,
with the above, it will be very different.



   --cw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
