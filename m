Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 044B26B005A
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:31:55 -0400 (EDT)
Received: from rtp-core-1.cisco.com (rtp-core-1.cisco.com [64.102.124.12])
	by rtp-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id n4JHWOd4032601
	for <linux-mm@kvack.org>; Tue, 19 May 2009 13:32:24 -0400
Received: from xbh-rtp-211.amer.cisco.com (xbh-rtp-211.cisco.com [64.102.31.102])
	by rtp-core-1.cisco.com (8.13.8/8.13.8) with ESMTP id n4JHWN3U016319
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:32:24 GMT
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: FW: process virtual size versus resident size versus swap space versus oom-killer
Date: Tue, 19 May 2009 13:35:06 -0400
Message-ID: <2FE093E39DAE7D498A29AF6BE01F267B052B73AE@xmb-rtp-20c.amer.cisco.com>
From: "Nick Hennenfent (nhennefe)" <nhennefe@cisco.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


=20
I have an embedded system where the resident size of a process continues
to grow and grow
until a lot of pages have been swapped, then the oom-killer kicks in and
kills it.
=20
How can I tell what processes or parts of processes are being swapped
out????
=20
How can I tell what has triggered the oom-killer - is it an application
allocation or a kernel allocation???
=20
How can I tell what part of a program is causing the resident set size
to grow????
=20
The virtual size of the process is much larger than the resident size,
as I understand it, the resident size grows as pages become "active".
=20
=20
=20
=20
=20
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
