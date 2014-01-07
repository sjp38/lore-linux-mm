Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 041326B0036
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 05:34:04 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so168382bkz.41
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 02:34:04 -0800 (PST)
Received: from mail-bk0-x22a.google.com (mail-bk0-x22a.google.com [2a00:1450:4008:c01::22a])
        by mx.google.com with ESMTPS id qd1si24039338bkb.205.2014.01.07.02.34.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 02:34:04 -0800 (PST)
Received: by mail-bk0-f42.google.com with SMTP id w11so174012bkz.1
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 02:34:03 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 7 Jan 2014 16:04:03 +0530
Message-ID: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com>
Subject: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

I would like to attend LSF/MM summit. I will like to discuss approach
to be taken to finally bring up a Union Filesystem for Linux kernel.

My tryst with Union Filesystem began when I was involved developing a
filesystem as a part of  GSOC2013(Google Summer of Code) for CERN
called Hepunion Filesystem.

CERN needs a union filesystem for LHCb to provide fast diskless
booting for its nodes. For such an implementation, they need a file
system with two branches a Read-Write and a Read Only so they decided
to write a completely new union file system called Hepunion. The
driver was  partially completed and worked somewhat with some issues
on 2.6.18. since they were using SCL5(Scientific Linux),

Now since LHCb is  moving to newer kernels, we ported it to newer
kernels but this is where the problem started. The design of our
filesystem was this that we used "path" to map the VFS and the lower
filesystems. With the addition of RCU-lookup in 2.6.35, a lot of
locking was added  in kernel functions like kern_path and made our
driver unstable beyond repair.

So now we are redesigning the entire thing from scratch.

We want to develop this Filesystem to finally have a stackable union
filesystem for the mainline Linux kernel . For such an effort,
collaborative development and community support is a must.


For the redesign, AFAIK
I can think of two ways to do it-

 1. VFS-based stacking solution- I would like to cite the work done by
Valerie Aurora was closest.

 2. Non-VFS-based stacking solution -  UnionFS, Aufs and the new Overlay FS

Patches for kernel exists for overlayfs & unionfs.
What is  communities view like which one would be good fit to go with?

The use case that I am looking from the stackable filesystem is  that
of "diskless node handling" (for CERN where it is required to provide
a faster diskless
booting to the Large Hadron Collider Beauty nodes).

 For this we need a
1. A global Read Only FIlesystem
2. A client-specific Read Write FIlesystem via NFS
3. A local Merged(of the above two) Read Write FIlesystem on ramdisk.

Thus to design such a fileystem I need community support and hence
want to attend LSF/MM summit.

  Regards,
  Saket Sinha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
