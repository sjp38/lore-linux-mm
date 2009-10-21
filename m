Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E97DC6B004D
	for <linux-mm@kvack.org>; Wed, 21 Oct 2009 14:27:13 -0400 (EDT)
Date: Wed, 21 Oct 2009 12:27:11 -0600
From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH 1/5] mm: add numa node symlink for memory section in
	sysfs
Message-ID: <20091021182711.GI23948@ldl.fc.hp.com>
References: <20091019212740.32729.7171.stgit@bob.kio> <20091019213415.32729.86034.stgit@bob.kio> <c18f2c2738f6a584b431324b38f21970.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c18f2c2738f6a584b431324b38f21970.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Gary Hade <garyhade@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> Alex Chiang wrote:
> > Commit c04fc586c (mm: show node to memory section relationship with
> > symlinks in sysfs) created symlinks from nodes to memory sections, e.g.
> >
> > /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> >
> > If you're examining the memory section though and are wondering what
> > node it might belong to, you can find it by grovelling around in
> > sysfs, but it's a little cumbersome.
> >
> > Add a reverse symlink for each memory section that points back to the
> > node to which it belongs.
> >
> > Cc: Gary Hade <garyhade@us.ibm.com>
> > Cc: Badari Pulavarty <pbadari@us.ibm.com>
> > Cc: Ingo Molnar <mingo@elte.hu>
> > Signed-off-by: Alex Chiang <achiang@hp.com>
> 
> 2 yeas ago, I wanted to add this symlink. But don't...because
> some vendor's host has no 1-to-1 relationship between a memsection
> and a node. (I don't remember precisely, sorry....s390?)

Hm, ok. I'll cc the s390 folks in the next version of this series.

Thanks for the pointer.

/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
