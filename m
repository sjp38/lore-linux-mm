Received: from www23.ureach.com (IDENT:root@www23.ureach.com [172.16.2.51])
	by ureach.com (8.9.1/8.8.5) with ESMTP id HAA23909
	for <linux-mm@kvack.org>; Fri, 6 Jul 2001 07:14:51 -0400
Date: Fri, 6 Jul 2001 07:14:51 -0400
Message-Id: <200107061114.HAA13294@www23.ureach.com>
From: Kapish K <kapish@ureach.com>
Reply-to: <kapish@ureach.com>
Subject: vmalloc limits
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
    we were looking at some code to understand the vmalloc
limits under different memory ranges and the capacity to change
them and their implications. Here's our understanding and we
would like to know the implications of some changes as well...
MAXMEM actually specifies the maximum physical RAM that is
addressible in the kernel virtual memory.
So, under the current i386 code of an intel 32 bit machine, with
a VMALLOC_RESERVE value of 128mb, it implies that this MAXMEM is
around 896mb ( 1024mb - 128mb ). So, our understanding is this:
on systems with physical ram less than this MAXMEM capacity, the
end of physical ram mapped kernel virtual address space marks
the beginning of vmalloc area, i.e., VMALLOC_START. However, in
the limiting case of ram equalling the MAXMEM value, the
VMALLOC_RESERVE value determines the start of vmalloc area,
which implies that on such systems with ram >= say 896 mb,
VMALLOC_RESERVE decides how much area is available for vmalloc.
I suppose this understanding is right. If not please point the
place where I may be going wrong. 
Now, if we were to increase the VMALLOC_RESERVE to a higher
value of say 256 mb or so, that would mean increasing the
vmalloc area. But what other subtle implications might this
have? 
of course, another option as someone already suggested on this
list ( there was an earlier discussion on vmalloc on this list )
about changing the page_offset value and thereby increasing the
size, but we would be interested in the higher memory cases,
where the limiting VMALLOC_RESERVE would determine the vmalloc
area.
Any pointers or hints to known issues with this kind of change
will be welcome. We can follow it up from thereon.
Thanks in Advance

________________________________________________
Get your own "800" number
Voicemail, fax, email, and a lot more
http://www.ureach.com/reg/tag
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
