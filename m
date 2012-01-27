Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id AFBE06B005A
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 12:19:39 -0500 (EST)
MIME-Version: 1.0
Message-ID: <f6fc422f-fbc2-4a19-b723-82c23f6aa3fe@default>
Date: Fri, 27 Jan 2012 09:19:44 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [LSF/MM TOPIC] [ATTEND] mm track: RAM utilization and page
 replacement topics
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Some (related) topics proposed for the MM track:

1) Optimizing the utilization of RAM as a resource, i.e. how do we teach th=
e
   kernel to NOT use all RAM when it doesn't really "need" it.  See
   http://lwn.net/Articles/475681/ (or if you don't want to read the whole
   article, start with "Interestingly, ..." four paragraphs from the end).

2) RAMster now exists and works... where are the holes and what next?
   http://marc.info/?l=3Dlinux-mm&m=3D132768187222840&w=3D2=20

3) Next steps in the page replacement algorithm:
=09a) WasActive https://lkml.org/lkml/2012/1/25/300=20
=09b) readahead http://marc.info/?l=3Dlinux-scsi&m=3D132750980203130=20

4) Remaining impediments for merging frontswap

5) Page flags and 64-bit-only... what are the tradeoffs?

Thanks,
Dan Magenheimer
"Mr. Tmem"
http://lwn.net/Articles/454795/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
