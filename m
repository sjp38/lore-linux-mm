Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC546B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:15:38 -0400 (EDT)
From: "Seger, Mark" <mark.seger@hp.com>
Date: Thu, 12 Mar 2009 13:14:15 +0000
Subject: New release of collectl now supports NFS V4 and buddyinfo
Message-ID: <9FCE3A46FE7C8045A6207AE4B42E9F9A4792FDA420@GVW1119EXC.americas.hpqcorp.net>
References: <477FDAA8.2030001@hp.com>
In-Reply-To: <477FDAA8.2030001@hp.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "util-linux-ng@vger.kernel.org" <util-linux-ng@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Just a quick note on this.  If you've been staying away from collectl becau=
se it didn't support V4 of nfs, I finally got around to adding it.  One thi=
ng that's kind of cool is if you run the command "collectl -sF --home", you=
'll see a top-like command that displays most of the nfs stats on all types=
 of the systems' nfs client/servers for versions 2,3 and 4.  You can read a=
 little more about it at: http://collectl.sourceforge.net/NfsInfo.html

While I was at it I also added buddyinfo monitoring, so you can literally w=
atch your fragment distribution change in real-time using the command "coll=
ectl -sB --home" as described here - http://collectl.sourceforge.net/BuddyI=
nfo.html.  I'm still not sure how one can make the most out of this informa=
tion or if I'm displaying it in the most useful manner, but as always all f=
eedback is welcome, preferably on the collectl mailing list collectl-intere=
st@lists.sourceforge.net.

-mark


=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
