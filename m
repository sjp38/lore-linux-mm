Message-ID: <A33AEFDC2EC0D411851900D0B73EBEF766E161@NAPA>
From: Hua Ji <hji@netscreen.com>
Subject: About 32M hash table
Date: Sun, 10 Jun 2001 16:28:33 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-user@lists.linuxppc.org, linuxppc-embedded@lists.linuxppc.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, folks,

Got an issue. Thanks in advance.

I tried to build a 32M page table for my 750-based system. From the linux
ppc source codes(head.S or hashtable.S from the MVista Inc.), the
**hash_page** function is the one who does the work. 

I tested with 256k page table size, it works. However, after I changed to
32M page table setting, the hashed value is not correct/same as I mannually
get:

Hash_Base = 0x8000000 //Hence, it is 32M aligned

Hash_bits =19 //So that 26-19=7; In other words, the total 9 bits(7th-15th)
frin primiary hash will get involved. From 256K page table, the Hash_bits is
12, which means the (26-12)th and 15th bits will be used for hash function.
----------------------

For example, when I map the 0x1d000000, the value calculated with
specification would be: 0x08340040; But
with the linux codes, the value is: 0x08740040, which was proved being
wrong(I was able to get the exception when enabled the mmu.


The only thing I assume for changing to 32M is the above :Hash_base and the
Hash_bits. I guess I missed some points. Any advice is highly appreciated. 

Thanks,

Mike



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
