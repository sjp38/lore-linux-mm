Date: Mon, 29 Sep 2003 12:14:47 +0100
From: Dave Jones <davej@redhat.com>
Subject: Re: 2.6.0-test6-mm1
Message-ID: <20030929111447.GA21451@redhat.com>
References: <20030928191038.394b98b4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030928191038.394b98b4.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 28, 2003 at 07:10:38PM -0700, Andrew Morton wrote:
 
 > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test6/2.6.0-test6-mm1

Debug: sleeping function called from invalid context at include/linux/rwsem.h:43
in_atomic():0, irqs_disabled():1
Call Trace:
 [<02123550>] do_page_fault+0x0/0x588
 [<021291be>] __might_sleep+0x9e/0xc0
 [<021237e0>] do_page_fault+0x290/0x588
 [<02135a85>] update_process_times+0x45/0x50
 [<02113ab8>] timer_interrupt+0x188/0x1e0
 [<0210ea0b>] do_IRQ+0x18b/0x230
 [<02123550>] do_page_fault+0x0/0x588


		Dave

-- 
 Dave Jones     http://www.codemonkey.org.uk
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
