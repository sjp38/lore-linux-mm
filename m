Message-Id: <l03130325b745dbca4a2f@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0106072042340.1156-100000@freak.distro.conectiva>
References: <l03130322b745b6bd9598@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 8 Jun 2001 02:35:47 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] VM tuning patch, take 2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>-       free += (dentry_stat.nr_unused * sizeof(struct dentry)) >>PAGE_SHIFT;
>-       free += (inodes_stat.nr_unused * sizeof(struct inode)) >> PAGE_SHIFT;
>+       /* free += (dentry_stat.nr_unused * sizeof(struct dentry)) >>
>PAGE_SHIFT;
>+          free += (inodes_stat.nr_unused * sizeof(struct inode)) >>
>PAGE_SHIFT;
>+        */
>
>
>On workloads full of dentries/inodes, allocations are going to fail with
>this change (remember most dentries/inodes _are_ usually freeable).

OK.  I made that change to help bring vm_enough_memory() and
out_of_memory() in line with each other, so if we put that back in, it
needs to be put in out_of_memory() as well.

As it happens, the dentry and inode caches get shrunk under VM pressure,
and so by the time swap is full and buffers+cache are a minimum size, these
caches will normally also be shrunk to their furthest sensible extent.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
