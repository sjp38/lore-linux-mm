Message-ID: <55E277B99171E041ABF5F4B1C6DDCA0683F06F@haritha.hclt.com>
From: "Somshekar. C. Kadam - CTD, Chennai." <som_kadam@ctd.hcltech.com>
Subject: RE: bootmem ?
Date: Sat, 14 Sep 2002 14:14:44 +0530
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravi <kravi26@yahoo.com>, "Somshekar. C. Kadam - CTD, Chennai." <som_kadam@ctd.hcltech.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi Ravi,
    Thanks for ur response definately it helps me,
 
 but i want to know what is the value of node_boot_start as u said it is set
to zero means what does it mean boot node is located at 0th loaction fo ram 
is correct
regards 
som
-----Original Message-----
From: Ravi [mailto:kravi26@yahoo.com]
Sent: Friday, September 13, 2002 11:41 PM
To: Somshekar. C. Kadam - CTD, Chennai.
Cc: linux-mm@kvack.org
Subject: Re: bootmem ?



> struct bootmem_data
> unsigned long node_boot_start what for 
 
  node_boot_start always gets set to 0.
 
> void *node_bootmem_map what is this  for 
>
>  if i am right node_bootmem_map is a pointer to beginig of bitmap
> that is the end of kernel

  init_bootmem_core() creates a bitmap representing all pages available
to the bootmem allocator. To make sure this bitmap doesn't overwrite 
kernel text or data, the address beyond end of kernel is passed
to init_bootmem_core(). The location of this bitmap is stored in
node_bootmem_map.
  
 
>    what should be the value of node_boot_start 
 
>  i am having 32 mb ram 
>    my kernel is loaded from 0x400 after 1mb(including text data and
> bss) which is end of kernel 
> i am setting node_boot_start as the pouinter to bit map  storing 
> bitmap after the end of the kernel

 I didn't understand what you meant by that. Why do you have to set
node_boot_start? You just need to call init_bootmem() with the
right parameters - a safe address for creating the bootmem bitmap
and number of pages available to the bootmem allocator. 
  After initializing bootmem allocator, you have to make sure that
pages where kernel is loaded and the pages containing the bootmem
bitmap itself are marked reserved.

Hope this helps,
Ravi.

__________________________________________________
Do you Yahoo!?
Yahoo! News - Today's headlines
http://news.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
