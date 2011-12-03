Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D6B3A6B0047
	for <linux-mm@kvack.org>; Sat,  3 Dec 2011 07:19:24 -0500 (EST)
Received: by iapp10 with SMTP id p10so3898684iap.14
        for <linux-mm@kvack.org>; Sat, 03 Dec 2011 04:19:22 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 3 Dec 2011 13:19:22 +0100
Message-ID: <CAOY=C6HuVEYpkap3dVmgmC7d+SDhvO-zc79RvCvkZCham3MiXg@mail.gmail.com>
Subject: Oops in d_instantiate (fs/cache.c)
From: Stijn Devriendt <highguy@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi all,

I've had 2 occasions where udev crashed during bootup.
The second time carried a kernel log where the following line
"BUG_ON(!list_empty(&entry->d_alias))"
in d_instantiate is triggered when udev is attempting to
create a symlink in /dev (which is tmpfs/shmem).

I've tried reproducing this by doing as udev does:
- create temporary symlink
- move temporary symlink into place
in a tight loop (multiple processes) while multiple
other processes were removing the symlink in a
tight loop.
A third script was flushing the dentry/inode cache
every so often using drop_caches.
All to no avail.

I've been digging around in the kernel sources,
but I'm not sure what the d_alias field means
and what the actual case is the BUG_ON is
meant to catch. I'd like to be able to find a way
to reproduce this, because so far it's happened only
twice in 2 weeks over multiple systems doing
many reboots in a testing setup.
Can someone explain this to me in short?

Thanks,
Stijn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
