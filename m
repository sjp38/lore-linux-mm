Message-ID: <55E277B99171E041ABF5F4B1C6DDCA0683E8AC@haritha.hclt.com>
From: "Somshekar. C. Kadam - CTD, Chennai." <som_kadam@ctd.hcltech.com>
Subject: RE: meminfo or Rephrased helping the Programmer's help themselves
	...
Date: Fri, 13 Sep 2002 13:30:13 +0530
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Carter <john.carter@tait.co.nz>, "M. Edward Borasky" <znmeb@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi ,
 i am newbie to linux mm trying to understand bootmem allocator
struct bootmem_data
unsigned long node_boot_start what for 



void *node_bootmem_map what is this  for 

 if i am right 
           node_bootmem_map is apointer to beginig of bitmap that is the end
of kernel


   what should be the value of node_boot_start 

 i am having 32 mb ram 
 
   my kernel is loaded from 0x400 after 1mb(including text data and bss)
which is end of kernel 
 i am setting node_boot_start as the pouinter to bit map 
storing bitmap after the end of the kernel

what should be the value given to node_boot_start

 any idea pls 
thanks in advnce 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
