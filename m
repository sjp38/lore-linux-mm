Received: from inter-tax.com (inter-tax.pclink.com [206.11.10.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id NAA09196
	for <linux-mm@kvack.org>; Thu, 8 Apr 1999 13:29:23 -0400
Received: from edison [192.168.1.2] by inter-tax.com [192.168.1.1] with SMTP (MDaemon.v2.7.SP4.R) for <linux-mm@kvack.org>; Thu, 08 Apr 1999 12:23:35 -0500
Message-ID: <013f01be81e4$88f07860$0201a8c0@edison.inter-tax.com>
From: "Keith Morgan" <kmorgan@inter-tax.com>
Subject: persistent heap design advice
Date: Thu, 8 Apr 1999 12:23:36 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am interested in creating a persistent heap library and would
appreciate any suggestions on how to proceed. The 'persistent heap'
would be a region of virtual memory backed by a file and could be
expanded or contracted.

In order to build my 'persistent heap' it seems like I need a
fundamental facility that isn't provided by Linux. Please correct me if
I'm wrong! It would be something like mmap() ... but different. The
facility call it phmap for starters) would:

-map virtual addresses to a user-specified file
-coordinate the expansion/contraction of the file and the virtual
address space
-provide ram cache [of user-specified number of pages (cache itself is
nonpagable)]*
-provide load-on-demand of data from the file into the cache
-swap LRU pages back to the file when cache full

[]* I'm not sure if this is the right approach. I want to avoid paging
out user program/data when traversing very large 'persistent heaps'.

I an interested in writing at the highest possible level to create the
phmap facility. At this point my questions are very broad (I'm not
looking for a cookbook, just trying to prune the search space):

-Is is possible to hack the mmap() source to create it?
-If not, are there kernel/vm hooks that can be used to create it?
-If not these, how can it be done? (hopefully without hacking into the
kernel)

I've read the LDP documents on the memory architecture and Linux Device
Drivers is on its way from amazon.com. I am also starting to read the mm
and arch/../mm source but I must admit that I don't have a coherent
picture of memory management yet. Thanks for any insight.

Keith Morgan


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
