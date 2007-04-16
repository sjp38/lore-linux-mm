Date: Sun, 15 Apr 2007 23:56:03 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: BUG:  Bad page state errors during kernel make
Message-ID: <20070416035603.GD21217@redhat.com>
References: <4622EDD3.9080103@zachcarter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4622EDD3.9080103@zachcarter.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Carter <linux@zachcarter.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 15, 2007 at 08:30:27PM -0700, Zach Carter wrote:

 > Console Messages:
 > Bad page state in process 'cc1'
 > page:c1ca88e8 flags:0x52000000 mapping:c1000000 mapcount:0 count:0
 > Trying to fix it up, but a reboot is needed
 > Backtrace:
 >   [<c015625d>] bad_page+0x5e/0x89
 >   [<c0156ab1>] get_page_from_freelist+0x1de/0x298
 >   [<c0156bd3>] __alloc_pages+0x68/0x2aa
 >   [<c016322a>] anon_vma_prepare+0x20/0xb8
 >   [<c0129647>] tasklet_action+0x4b/0xa4
 >   [<c015e336>] __handle_mm_fault+0x3b2/0x88f
 >   [<c0116dce>] smp_apic_timer_interrupt+0x6e/0x7a
 >   [<c01380d7>] hrtimer_run_queues+0x138/0x152
 >   [<c0315e4a>] do_page_fault+0x23f/0x53c
 >   [<c0315c0b>] do_page_fault+0x0/0x53c
 >   [<c031488c>] error_code+0x7c/0x84
 >   =======================
 > list_del corruption. prev->next should be c21a4628, but was e21a4628

'c' became 'e' in that last address. A single bit flipped.
Given you've had this for some time, this smells like a hardware problem.
memtest86+ will probably show up something.

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
