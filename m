Subject: 2.5.41-mm1 oops on boot (EIP at kmem_cache_alloc)
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 09 Oct 2002 09:33:36 -0600
Message-Id: <1034177616.1306.180.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Greetings,

I got an oops when booting 2.5.41-mm1 on my dual p3.
More configuration information available if needed.

I had to copy this down by hand, so only a minimal amount of information
was saved.  If more data is needed, I can repeat the boot.

EIP is at kmem_cache_alloc+0x18/0x50

Call Trace:
call_console_drivers+0xeb/0x100
kmem_cache_create+0x6f/0x560
release_console_sem+0x62/0xe0
init+0x51/0x1d0
init+0x0/0x1d0
kernel_thread_helper+0x5/0x10

Code: 8b 02 85 c0 74 12 c7 42 0c 00 00 00 48 89 02 8b 44 02 10

I was able to boot and run 2.5.41-bk2 on this same machine.

Steven





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
