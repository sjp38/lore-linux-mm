Received: by fg-out-1718.google.com with SMTP id 19so6355256fgg.4
        for <linux-mm@kvack.org>; Wed, 23 Jul 2008 02:40:00 -0700 (PDT)
Message-ID: <4886FBEF.5030706@gmail.com>
Date: Wed, 23 Jul 2008 11:37:51 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: WARNING: at arch/x86/mm/pageattr.c:591 __change_page_attr_set_clr
 [mmotm]
References: <4886FA7C.8060809@gmail.com>
In-Reply-To: <4886FA7C.8060809@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On 07/23/2008 11:31 AM, Jiri Slaby wrote:
> mmotm 2008-07-15-15-39 while booting:
> 
> EXT3 FS on dm-0, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> ------------[ cut here ]------------
> WARNING: at arch/x86/mm/pageattr.c:591 
> __change_page_attr_set_clr+0x627/0x990()
> CPA: called for zero pte. vaddr = ffff88007d5b0000 cpa->vaddr = 
> ffff88007d5b0000

Hmm, I think it's known:
http://marc.info/?l=linux-acpi&m=121607842728729&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
