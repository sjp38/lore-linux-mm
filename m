Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 39517900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:38:40 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <67d72d8f-9809-4e43-9e90-417d4eb14db1@default>
Date: Fri, 15 Apr 2011 12:37:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V8 1/8] mm/fs: cleancache documentation
References: <20110414211601.GA27691@ca-server1.us.oracle.com
 87mxjr4a6o.fsf@devron.myhome.or.jp>
In-Reply-To: <87mxjr4a6o.fsf@devron.myhome.or.jp>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

Hi Hirofumi-san --

> Another question: why can't this enable/disable per sb, e.g. via mount
> options? (I have the interest the cache stuff like this by SSD on
> physical systems like dragonfly's swapcache.)

This would be useful and could be added later if individual
filesystems choose to add the mount functionality.  My goal with
this patchset is to enable only minimal functionality so
that other kernel developers can build on it.

> Well, anyway, I guess force enabling this for mostly unused sb can just
> add cache-write overhead and call for unpleasing reclaim to backend
> (because of limited space of backend) like updatedb.

If the sb is mostly unused, there should be few puts.  But you
are correct that if the backend has only very limited space,
cleancache adds cost and has little value.  On these systems,
cleancache should probably be disabled.  However, the cost
is very small so leaving it enabled may not even show a
measureable performance impact.

> And already there is in FAQ though, I also have interest about async
> interface because of SDD backend (I'm not sure for now though). Is
> there any plan like SSD backend?

Yes, I think an SSD backend is very interesting, especially
if the SSD is "very near" to the processor so that it can
be used as a RAM extension rather than as an I/O device.

The existing cleancache hooks will work for this and I am
working on a cleancache backend called RAMster that will
be a good foundation to access other asynchronous devices.
See: http://marc.info/?l=3Dlinux-mm&m=3D130013567810410&w=3D2=20

Thanks for your feedback!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
