Date: Mon, 6 Aug 2007 18:38:51 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Help understanding SPARC32 Sun4c PTE handling
Message-ID: <Pine.LNX.4.61.0708061749230.29956@mtfhpc.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

If you have the time ..., if not, hopfully, some one from linux-mm will 
explain.

I have been investigating the differences between SunOS PTE and Linux PTE 
bits. There are some differences that I would like to understand.

What is the pte_file() function intended for. The bit in the PTE that
is used (0x02000000) is set by hardware (definatly on page write and in 
theory on page read if the SunOS PTE description is to be believed. It 
is described as the 'refferenced' bit).

The linux-mm documentation only states that it is for swappable non-linear 
VMAs (exactly what we have in the sun4c unless you assume VMA is signed 
[like the INMOS Transputer], in which case it is linear from -512MB to 
+512MB :-). The down size of sigend address mappings is that NULL is 
nolonger zero and too many people have got lazy and assumed it is.).

Re-arranging the bits so that _SUN4C_PAGE_ACCESSED and 
_SUN4C_PAGE_MODIFIED bits match the MMU hardware bits seems to make boots 
more stable (I have been gettimg non-repeatable boots where the init 
script goes through the motions but does not actually do what I am 
expecting or just gets skipped. SLAB is worse than SLUB.) but the changes 
I have tried sofar, break swapon.

Linux uses four bits that do not get saved in the MMU PTE 
(_SUN4C_PAGE_READ, _SUN4C_PAGE_WRITE, _SUN4C_PAGE_MODIFIED and 
_SUN4C_PAGE_ACCESSED). I have assumed that these are preserved externally 
in a software copy of the PTE somewhere (I have not found anything that I 
recognise as specific storage for this in the sparc32 code) as reading the 
MMU PTE will return zero for these bits.

Regards
 	Mark Fortescue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
