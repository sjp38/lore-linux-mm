Date: Sun, 16 Jan 2005 12:36:39 +0800
From: Bernard Blackham <bernard@blackham.com.au>
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
Message-ID: <20050116043639.GE24653@blackham.com.au>
References: <20050113085626.GA5374@blackham.com.au> <20050113101426.GA4883@blackham.com.au> <41E8ED89.8090306@yahoo.com.au> <1105785254.13918.4.camel@desktop.cunninghams> <41E8F313.4030102@yahoo.com.au> <1105786115.13918.9.camel@desktop.cunninghams> <41E8F7F7.1010908@yahoo.com.au> <20050115124018.GA24653@blackham.com.au> <20050115125311.GA19055@blackham.com.au> <41E9E5B6.1020306@yahoo.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Dxnq1zWXvFF0Q93v"
Content-Disposition: inline
In-Reply-To: <41E9E5B6.1020306@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: ncunningham@linuxmail.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jan 16, 2005 at 02:55:34PM +1100, Nick Piggin wrote:
> Someone asked for an order 10 allocation by the looks.
> 
> This might tell us what happened.

Yep. Attached. Appears Software Suspend is asking for it as part of
it's memory grab. Perhaps wakeup_kswapd just needs to be disabled
while suspending? Nigel?

Bernard.

-- 
 Bernard Blackham <bernard at blackham dot com dot au>

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=kswapd-dmesg

Software Suspend 2.1.5.13: Initiating a software suspend cycle.

** Freezing processes

** Freezing processes: Syncing remaining I/O.
kswapd: balance_pgdat, order = 0

** Eating memory.
wakeup_kswapd(order = 10)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01328b2>] __grab_free_memory+0xf2/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 10)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01328b2>] __grab_free_memory+0xf2/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01328b2>] __grab_free_memory+0xf2/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01328b2>] __grab_free_memory+0xf2/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01328b2>] __grab_free_memory+0xf2/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01328b2>] __grab_free_memory+0xf2/0x110
 [<c01328dc>] grab_free_memory+0xc/0x20
 [<c0133055>] eat_memory+0x2e5/0x5a0
 [<c0133458>] prepare_image+0x148/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75

** Preparing page directory.
wakeup_kswapd(order = 10)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01336d1>] add_extent_pages+0xa1/0x150
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 10)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01336d1>] add_extent_pages+0xa1/0x150
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01336d1>] add_extent_pages+0xa1/0x150
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01336d1>] add_extent_pages+0xa1/0x150
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01336d1>] add_extent_pages+0xa1/0x150
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01336d1>] add_extent_pages+0xa1/0x150
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 10)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01345a6>] get_extentpages_list+0x116/0x160
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 10)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01345a6>] get_extentpages_list+0x116/0x160
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01345a6>] get_extentpages_list+0x116/0x160
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 9)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01345a6>] get_extentpages_list+0x116/0x160
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01345a6>] get_extentpages_list+0x116/0x160
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75
wakeup_kswapd(order = 8)
 [<c01033de>] dump_stack+0x1e/0x20
 [<c014aea5>] wakeup_kswapd+0x55/0xd0
 [<c0143e3d>] __alloc_pages+0xed/0x340
 [<c01327ea>] __grab_free_memory+0x2a/0x110
 [<c0132b41>] get_grabbed_pages+0x161/0x2e0
 [<c01345a6>] get_extentpages_list+0x116/0x160
 [<c0133890>] get_extent+0x60/0x70
 [<c0133e67>] add_to_extent_chain+0x117/0x2e0
 [<c013bc7a>] swapwriter_allocate_storage+0x8a/0x280
 [<c01323eb>] update_image+0x9b/0x470
 [<c013348e>] prepare_image+0x17e/0x320
 [<c0135d94>] do_activate+0xf4/0x670
 [<c012e592>] suspend2_try_suspend+0x42/0x50
 [<c012e828>] suspend2_write_proc+0xf8/0x1e0
 [<c015caed>] vfs_write+0x11d/0x160
 [<c015cbfb>] sys_write+0x4b/0x80
 [<c0102e4d>] sysenter_past_esp+0x52/0x75

** Preparing page directory.

** Starting to save the image..

** Writing caches...

** Suspending drivers.

** Doing atomic copy...

** Resuming drivers.
ACPI: PCI interrupt 0000:00:10.0[A]: no GSI - using IRQ 15

** Reading caches...
e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex

** Cleaning up...
kswapd: balance_pgdat, order = 10
Please include the following information in bug reports:
- SUSPEND core   : 2.1.5.13
- Kernel Version : 2.6.11-rc1
- Compiler vers. : 3.4
- Modules loaded : 
- Attempt number : 1
- Pageset sizes  : 3197 (3197 low) and 8649 (8649 low).
- Parameters     : 0 2049 0 7 0 5
- Calculations   : Image size: 11850. Ram to suspend: 652.
- Limits         : 65520 pages RAM. Initial boot: 62995.
- Overall expected compression percentage: 0.
- LZF Compressor enabled.
  Compressed 48521216 bytes into 21593026 (55 percent compression).
- Swapwriter active.
  Swap available for image: 125234 pages.
- Debugging compiled in.
- Max extents used: 4 extents in 1 pages.
- I/O speed: Write 18 MB/s, Read 15 MB/s.

--Dxnq1zWXvFF0Q93v--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
