Message-ID: <20020106121023.77037.qmail@web21105.mail.yahoo.com>
Date: Sun, 6 Jan 2002 12:10:23 +0000 (GMT)
From: =?iso-8859-1?q?Pooja=20Gupta?= <pooja_pict@yahoo.com>
Subject: Adding new zone in Linux MM
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello...
   I want to reserve some part of my physical memory
for my application which runs in kernel mode, say 20%
of my physical RAM or so.  
   For this, I was thinking to add a new zone in the
zone allocator of the current linux mm (linux 2.4.7 or
below).  This is so because, it will be easier for my
appication to handle those physical pages through
built in alloc_pages and free_pages.  I will define my
own ZONE_MYZONE and other parameters in the kernel
which will take care of all the bookkeeping.  Also one
advantage will be that the normal mm in linux will go
ahead working with lesser RAM without realizing the
presence of another new zone.  
    I wanted to know that how feasible is this idea
practially.  If it is feasible, can anyone suggest me
the GFPMASK for the new zone which is being unused
presently. 

(ps.  In kernel 2.4.4 there were 256 GFP_MASKS and in
kernel 2.4.7 there are just 16 of them....??? why??)

    Thanks in advance,
    Pooja.

________________________________________________________________________
Looking for a job?  Visit Yahoo! India Careers
      Visit http://in.careers.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
