Date: Thu, 15 Jan 2004 15:23:06 -0800
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: 2.6.1-mm2
Message-Id: <20040115152306.2c56d6e3.rddunlap@osdl.org>
In-Reply-To: <4004458C.5040000@gmx.de>
References: <20040110014542.2acdb968.akpm@osdl.org>
	<4003F34E.5080508@gmx.de>
	<20040113095428.440762f7.akpm@osdl.org>
	<400441BD.9020609@gmx.de>
	<20040113111639.60b681d2.akpm@osdl.org>
	<4004458C.5040000@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jan 2004 20:22:52 +0100 "Prakash K. Cheemplavam" <PrakashKC@gmx.de> wrote:

| Andrew Morton wrote:
| > "Prakash K. Cheemplavam" <PrakashKC@gmx.de> wrote:
| > 
| >>>>kernel: Badness in pci_find_subsys at drivers/pci/search.c:132
| >>>>
| >>>>Any ideas? Or do you need detailed kernel config and dmesg? I thought 
| >>>>you might have an idea which atch caused this... My and his system are 
| >>>>quite differnt. Major Common element seems only use of Athlon XP. He has 
| >>>>VIA KT based system and I have nforce2. I thought it might be APIC, but 
| >>>>I also got a lock up without APIC. (Though it seems more stable without 
| >>>>APIC.)
| >>>
| >>>
| >>>If you could send us the stack backtrace that would help.  Make sure that
| >>>you have CONFIG_KALLSYMS enabled.  If you have to type it by hand, just the
| >>>symbol names will suffice - leave out the hex numbers.
| >>
| >>Sorry, I am a noob about such things. Above option is enabled in my 
| >>config, but I dunno how get the stack backtrace. Could you point to me 
| >>to something helpful?
| > 
| > 
| > When the kernel prints that `badness' message it then prints a stack
| > backtrace.  That's what we want.
| 
| But how to get that? When the machine locks up, I don't see anything 
| written and only *sometimes* I got above message in the log  -whcih I 
| can only see afterwards. But there is nothing else realted to it in the 
| log...

(I didn't see any replies to this...)

The usual answer is to use a serial console to log the kernel messages,
but not everyone has that option available to them.

Depending on your system, you might be able to use kmsgdump to
capture the final kernel messages to a floppy disk (if you have a
"legacy" type floppy).  If you are interested in trying that,
the kmsgdump patch is available at
  http://developer.osdl.org/rddunlap/kmsgdump/

--
~Randy
Everything is relative.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
