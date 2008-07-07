Received: by wf-out-1314.google.com with SMTP id 28so2388672wfc.11
        for <linux-mm@kvack.org>; Mon, 07 Jul 2008 00:32:42 -0700 (PDT)
Message-ID: <19f34abd0807070032wb6a2d50s99de5950132016f5@mail.gmail.com>
Date: Mon, 7 Jul 2008 09:32:41 +0200
From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: next-0704: WARNING: at kernel/sched.c:4254 add_preempt_count; PANIC
In-Reply-To: <487159DA.708@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <487159DA.708@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 7, 2008 at 1:48 AM, Alexander Beregalov
<a.beregalov@gmail.com> wrote:
> Hi
>
> WARNING: at kernel/sched.c:4254 add_preempt_count+0x61/0x63()
> Modules linked in: i2c_nforce2
> Pid: 3620, comm: rtorrent Not tainted 2.6.26-rc8-next-20080704 #5
>  [<c038e436>] ? printk+0xf/0x11
>  [<c011b681>] warn_on_slowpath+0x41/0x7b
>  [<c0157a94>] ? mmap_region+0x1c5/0x414
>  [<c0156499>] ? remove_vma+0x50/0x56
>  [<c0159836>] ? anon_vma_prepare+0x52/0xc5
...

> BUG: unable to handle kernel paging request at fffef4f1
> IP: [<c0103c53>] dump_trace+0xa5/0xe2
> *pde = 00007067 *pte = 00000000
> Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
> last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
> Modules linked in: i2c_nforce2
>
> Pid: 3620, comm: rtorrent Not tainted (2.6.26-rc8-next-20080704 #5)
> EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
> EIP is at dump_trace+0xa5/0xe2
> EAX: fffefffc EBX: fffef4f1 ECX: c0396978 EDX: c0455a08
> ESI: 5a5a5a5a EDI: f4d4c084 EBP: f4d4bf34 ESP: f4d4bf14

^--- POISON_INUSE

But I don't know if this is really significant, given that it's not
the first error you're getting. It may also be just a remnant of the
memset() that marks the SLUB objects as such. (Or something like
that.)

Too bad the recursive page fault stops us from getting the Code: line.

Config would be nice :-)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
