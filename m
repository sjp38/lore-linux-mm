Subject: Re: Memory allocation problem
Message-ID: <OF15CF6B9C.D9504382-ON86256D19.00484B29@hou.us.ray.com>
From: Mark_H_Johnson@Raytheon.com
Date: Thu, 1 May 2003 08:20:56 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: anand kumar <a_santha@rediffmail.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>The kernel version we are using is 2.4.18 (Redhat 8.0) and the total
>amount of memory available in the box is 128MB

>Is there any other mechanism to allocate large amount of physically
>contiguous memory blocks during normal run time of the driver? Is this
>being addressed in later kernels.

I regularly use a patch (bigphysarea) recommended by Dolphin for use with
their SCI cards. The copy I use is from a relatively old kernel (2.4.4)
which applies with a few warnings but is otherwise OK. I did a quick search
with Google for
  bigphysarea linux 2.4.18
and found
  http://frmb.home.cern.ch/frmb/download/bigphysarea-2.4.18.patch
or a more readable page at
  http://frmb.home.cern.ch/frmb/linux.html
which appears to be a version updated for 2.4.18. I believe the original
patch is maintained at
  http://www.uni-paderborn.de/fachbereich/AG/heiss/linux/bigphysarea.html

There are apparently several drivers that already use this interface, but
it does require a patched kernel.

I am not aware of any effort to merge this into the main line kernel
(though I would certainly appreciate that).

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
