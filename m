Date: Thu, 7 Jun 2001 20:44:14 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] VM tuning patch, take 2
In-Reply-To: <l03130322b745b6bd9598@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106072042340.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 7 Jun 2001, Jonathan Morton wrote:

> >> >>For comparison, what was the time taken by -j15 build before your patch?
> >> >
> >> >Plain 2.4.5 gives 6m20s, but uses 190Mb of swap to achieve that - nearly 3
> >> >times what my patched version does.  I could try adding more swap (on a
> >> >faster device) and see what make -j 20 does...
> >>
> >> On plain 2.4.5 and a 1Gb swapfile located on an Ultra160 10000rpm device,
> >> make -j 20 took 7m20s, peaking at 370Mb swap usage.  With the extra
> >> patches, it takes 6m30, peaking at 254Mb swap usage.  Looks like the new
> >> patches have a greater positive impact the higher the VM load.  :)
> >
> >>From your numbers I have seen no regressions/negative impact, so right
> >on :)
> 
> OK, the patch is now uploaded at:
> 
> http://www.chromatix.uklinux.net/linux-patches/vm-update-2.patch
> 
> I'd like people to go over it to make sure I've not boo-booed in some
> SMP-incompatible way, then the guys with the big machines and workloads can
> have a play.  It incorporates many if not most of the individual
> improvements posted here, as well as some additions of my own, so I
> strongly reccommend applying to a virgin 2.4.5 tree.

-       free += (dentry_stat.nr_unused * sizeof(struct dentry)) >>PAGE_SHIFT;
-       free += (inodes_stat.nr_unused * sizeof(struct inode)) >> PAGE_SHIFT;
+       /* free += (dentry_stat.nr_unused * sizeof(struct dentry)) >> PAGE_SHIFT;
+          free += (inodes_stat.nr_unused * sizeof(struct inode)) >> PAGE_SHIFT;
+        */


On workloads full of dentries/inodes, allocations are going to fail with
this change (remember most dentries/inodes _are_ usually freeable). 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
