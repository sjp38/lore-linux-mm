Received: from ariessys.com (ns.ariessys.com [198.115.92.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA08558
	for <linux-mm@kvack.org>; Wed, 28 Apr 1999 11:28:11 -0400
Received: from [198.115.92.60] (lightning.ariessys.com [198.115.92.60])
	by ariessys.com (8.8.8/8.8.8) with ESMTP id LAA05273
	for <linux-mm@kvack.org>; Wed, 28 Apr 1999 11:28:05 -0400
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Message-Id: <v04020a01b34cd7f3c7c3@[198.115.92.60]>
Date: Wed, 28 Apr 1999 11:28:07 -0400
From: "James E. King, III" <jking@ariessys.com>
Subject: Hello
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm not much of a kernel type, but I do have some formal background on OS
working and reading through the Linux-MM site brought back lots of stuff.

Anyway, I am working on a project where we have a large database split into
12 segments, and I want to put some of the indices in those segments into
memory.  The indices for all of the segments takes up about 4 GB.

The database server is a multi-threaded proprietary one that I ported over
to Linux - it already runs on MacOS (yes, true!), NT, Solaris, AIX.

I have a couple of questions (assume I am talking about the latest versions
of any component, like kernel or lilo or ramdisk):

1. If I purchase a Quad Xeon 550 with 4 GB of memory, will Linux work on it?
   (I saw the whole thing about tweaking kernel parameters to change from a 3:1
    split to a 2:2 split)
   Should I just buy 2GB - will I be able to use the extra 2GB?

2. Can I create a large (let's say 1GB) ramdisk or memory filesystem?

Obviously the more index I can fit into memory, the faster the result.

I'd really, really like to use Linux here.  It has proven itself as our
mail/DNS server and hasn't crashed once in over 2 years, where we reboot NT
servers weekly.

I am willing to do some kernel hacking and experimentation.  I have not
been able to find another resource related to large amounts of memory with
Linux.  Hopefully through my experiences I will be able to produce a Linux
VLM-HOWTO!

Thanks.

     _/   _/_/  _/_/_/ _/_/  _/_/         James E. King, III
    _/_/  _/ _/   _/   _/   _/            Aries Systems Corporation
   _/_/_/ _/_/    _/   _/_/  _/_/         200 Sutton Street
   _/  _/ _/ _/   _/   _/       _/        North Andover, MA.  01845
   _/  _/ _/ _/ _/_/_/ _/_/  _/_/         (978) 975-7570
                                          (978) 975-3811 FAX
      <http://www.kfinder.com/>
  Enhancing the Power of Knowledge(r)     jking@ariessys.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
