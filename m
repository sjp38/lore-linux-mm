Received: by yx-out-1718.google.com with SMTP id 36so41449yxh.26
        for <linux-mm@kvack.org>; Wed, 18 Jun 2008 09:12:03 -0700 (PDT)
Message-ID: <485933C7.8050801@gmail.com>
Date: Wed, 18 Jun 2008 18:11:51 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] MM: virtual address debug
References: <1213271800-1556-1-git-send-email-jirislaby@gmail.com> <20080618121221.GB13714@elte.hu> <20080618135928.GA12803@elte.hu>
In-Reply-To: <20080618135928.GA12803@elte.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Ingo Molnar <mingo@redhat.com>, tglx@linutronix.de, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, the arch/x86 maintainers <x86@kernel.org>, Mike Travis <travis@sgi.com>, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Ingo Molnar napsal(a):
> No NUMA configuration found
> Faking a node at 0000000000000000-000000003fff0000
> Entering add_active_range(0, 0, 159) 0 entries of 25600 used
> Entering add_active_range(0, 256, 262128) 1 entries of 25600 used
> Bootmem setup node 0 0000000000000000-000000003fff0000
>   NODE_DATA [000000000000a000 - 000000000003dfff]
> PANIC: early exception 06 rip 10:ffffffff80ba7531 error 0 cr2 f06f53
> Pid: 0, comm: swapper Not tainted 2.6.26-rc6 #7709
> 
> Call Trace:
>  [<ffffffff80b9c196>] early_idt_handler+0x56/0x6a
>  [<ffffffff80ba7531>] setup_node_bootmem+0x12a/0x2d4

Hmm, it's at
nid = phys_to_nid(nodedata_phys);
and
VIRTUAL_BUG_ON((addr >> memnode_shift) >= memnodemapsize);
triggers. Apparently memnodemapsize is not available for real numas. Going 
to remove the test and respin the patch with Nick's comment applied.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
