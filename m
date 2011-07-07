Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5F50F9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 01:30:30 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Hugepages for shm page cache (defrag)
References: <201107062131.01717.mail@smogura.eu>
Date: Wed, 06 Jul 2011 22:28:59 -0700
In-Reply-To: <201107062131.01717.mail@smogura.eu> (=?utf-8?Q?=22Rados?=
 =?utf-8?Q?=C5=82aw?= Smogura"'s
	message of "Wed, 6 Jul 2011 21:31:01 +0200")
Message-ID: <m2pqlmy7z8.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?Q?Rados=C5=82aw?= Smogura <mail@smogura.eu>
Cc: linux-mm@kvack.org, aarcange@redhat.com

Rados=C5=82aw Smogura <mail@smogura.eu> writes:

> Hello,
>
> This is may first try with Linux patch, so please do not blame me too muc=
h.=20
> Actually I started with small idea to add MAP_HUGTLB for /dev/shm but it =
grew=20
> up in something more like support for huge pages in page cache, but accor=
ding=20
> to documentation to submit alpha-work too, I decided to send this.

Shouldn't this be rather integrated with the normal transparent huge
pages? It seems odd to develop parallel infrastructure.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
