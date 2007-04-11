Received: by ug-out-1314.google.com with SMTP id s2so67514uge
        for <linux-mm@kvack.org>; Wed, 11 Apr 2007 02:14:46 -0700 (PDT)
Message-ID: <ac8af0be0704110214qdca2ee9t3b44a17341e53730@mail.gmail.com>
Date: Wed, 11 Apr 2007 17:14:46 +0800
From: "Zhao Forrest" <forrest.zhao@gmail.com>
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
In-Reply-To: <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
	 <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I enable CONFIG_DEBUG_SLAB, but don't get any extra debug messages
related to slab.
Is there other switch that I need to turn on?

Thanks,
Forrest

BUG: soft lockup detected on CPU#6!

Call Trace:
 <IRQ>  [<ffffffff800b3834>] softlockup_tick+0xdb/0xed
 [<ffffffff80093edf>] update_process_times+0x42/0x68
 [<ffffffff80074897>] smp_local_timer_interrupt+0x23/0x47
 [<ffffffff80074f59>] smp_apic_timer_interrupt+0x41/0x47
 [<ffffffff8005c7c2>] apic_timer_interrupt+0x66/0x6c
 <EOI>  [<ffffffff80043b09>] invalidate_mapping_pages+0xe1/0x15f
 [<ffffffff80043afa>] invalidate_mapping_pages+0xd2/0x15f
 [<ffffffff800d5bea>] kill_bdev+0xe/0x21
 [<ffffffff800d6110>] __blkdev_put+0x4f/0x169
 [<ffffffff80012785>] __fput+0xae/0x198
 [<ffffffff80023ca6>] filp_close+0x5c/0x64
 [<ffffffff80038e33>] put_files_struct+0x6c/0xc3
 [<ffffffff8001543d>] do_exit+0x2d2/0x8b1
 [<ffffffff80047932>] cpuset_exit+0x0/0x6c
 [<ffffffff8002b30f>] get_signal_to_deliver+0x427/0x456
 [<ffffffff80059b9e>] do_notify_resume+0x9c/0x7a9
 [<ffffffff8008776d>] default_wake_function+0x0/0xe
 [<ffffffff800b2b79>] audit_syscall_exit+0x2cd/0x2ec
 [<ffffffff8005be62>] int_signal+0x12/0x17


On 4/11/07, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> On 4/11/07, Zhao Forrest <forrest.zhao@gmail.com> wrote:
> > We're using RHEL5 with kernel version 2.6.18-8.el5.
> > When doing a stress test on raw device for about 3-4 hours, we found
> > the soft lockup message in dmesg.
> > I know we're not reporting the bug on the latest kernel, but does any
> > expert know if this is the known issue in old kernel? Or why
> > kmem_cache_free occupy CPU for more than 10 seconds?
>
> Sounds like slab corruption. CONFIG_DEBUG_SLAB should tell you more.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
