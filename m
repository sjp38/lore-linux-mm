Date: Tue, 13 Jan 2004 09:54:28 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1-mm2
Message-Id: <20040113095428.440762f7.akpm@osdl.org>
In-Reply-To: <4003F34E.5080508@gmx.de>
References: <20040110014542.2acdb968.akpm@osdl.org>
	<4003F34E.5080508@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Prakash K. Cheemplavam" <PrakashKC@gmx.de> wrote:
>
> Hi,
> 
> mm2 (or even mm1 or even vanilla, have not tested (long enough)) locks 
> hard on my and someone else' machine. Sometimes we get this line in our 
> logs before the lock happens:
> 
> kernel: Badness in pci_find_subsys at drivers/pci/search.c:132
> 
> Any ideas? Or do you need detailed kernel config and dmesg? I thought 
> you might have an idea which atch caused this... My and his system are 
> quite differnt. Major Common element seems only use of Athlon XP. He has 
> VIA KT based system and I have nforce2. I thought it might be APIC, but 
> I also got a lock up without APIC. (Though it seems more stable without 
> APIC.)

If you could send us the stack backtrace that would help.  Make sure that
you have CONFIG_KALLSYMS enabled.  If you have to type it by hand, just the
symbol names will suffice - leave out the hex numbers.

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
