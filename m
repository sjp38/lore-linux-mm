Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 610F79000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 15:31:10 -0400 (EDT)
Received: from cec151.neoplus.adsl.tpnet.pl ([83.30.178.151]:42761 helo=radek.localnet)
	by flawless.hostnac.com with esmtpa (Exim 4.69)
	(envelope-from <mail@smogura.eu>)
	id 1QeXoK-0004qX-TQ
	for linux-mm@kvack.org; Wed, 06 Jul 2011 15:31:01 -0400
From: =?utf-8?q?Rados=C5=82aw_Smogura?= <mail@smogura.eu>
Subject: Hugepages for shm page cache (defrag)
Date: Wed, 6 Jul 2011 21:31:01 +0200
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_1fLFOjjdXPuSMNe"
Message-Id: <201107062131.01717.mail@smogura.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--Boundary-00=_1fLFOjjdXPuSMNe
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello,

This is may first try with Linux patch, so please do not blame me too much.=
=20
Actually I started with small idea to add MAP_HUGTLB for /dev/shm but it gr=
ew=20
up in something more like support for huge pages in page cache, but accordi=
ng=20
to documentation to submit alpha-work too, I decided to send this.

=2D------------------
Idea is that I created defrag method which tries to defragment page cache t=
o=20
huge page, I added one flag for such compound page, as I want to treat it=20
little different, for example any put/get unless/test zero will increase it=
=20
count, so page will be freed if all "sub-pages" will be freed. From other s=
ide=20
each tail page may have it's own LRU (why I don't know).

There is ofocourse much work to do in shm to make it hugepage aware, map=20
pte(pde) etc.

At this stage I don't have BUGs and I can make 2MB shm area, read and delet=
e=20
it.
Signed-off-by: Rados=C5=82aw Smogura (mail@smogura.eu)
=2D------------------

Any suggestion are welcome.

If it's to early work I want to say sorry. I hope I fullfiled all code/subm=
it=20
conventions.

Regards,
Rados=C5=82aw Smogura



--Boundary-00=_1fLFOjjdXPuSMNe
Content-Type: application/x-gzip;
  name="defrag_page_cache_01.patch.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="defrag_page_cache_01.patch.gz"

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

--Boundary-00=_1fLFOjjdXPuSMNe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
