Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] VM tuning patch, take 2
Date: Thu, 7 Jun 2001 21:59:38 -0400
References: <l03130322b745b6bd9598@[192.168.239.105]> <l03130325b745dbca4a2f@[192.168.239.105]>
In-Reply-To: <l03130325b745dbca4a2f@[192.168.239.105]>
MIME-Version: 1.0
Message-Id: <01060721593800.06690@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>, Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 07 June 2001 21:35, Jonathan Morton wrote:
> >-       free += (dentry_stat.nr_unused * sizeof(struct dentry))
> > >>PAGE_SHIFT; -       free += (inodes_stat.nr_unused * sizeof(struct
> > inode)) >> PAGE_SHIFT; +       /* free += (dentry_stat.nr_unused *
> > sizeof(struct dentry)) >> PAGE_SHIFT;
> >+          free += (inodes_stat.nr_unused * sizeof(struct inode)) >>
> >PAGE_SHIFT;
> >+        */
> >
> >
> >On workloads full of dentries/inodes, allocations are going to fail with
> >this change (remember most dentries/inodes _are_ usually freeable).
>
> OK.  I made that change to help bring vm_enough_memory() and
> out_of_memory() in line with each other, so if we put that back in, it
> needs to be put in out_of_memory() as well.
>
> As it happens, the dentry and inode caches get shrunk under VM pressure,
> and so by the time swap is full and buffers+cache are a minimum size, these
> caches will normally also be shrunk to their furthest sensible extent.

Think you are right Jonathan.  This adding this back is _not_ going to make a 
difference.  With the changes Rik made for 2.4.5, these caches are agressivily
shrunk when there is free shortage...

So far so good with take 2 here.

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
