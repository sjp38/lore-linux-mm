Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 06CC56B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 07:47:15 -0400 (EDT)
Message-ID: <20100818114718.67877.qmail@web4201.mail.ogk.yahoo.co.jp>
Date: Wed, 18 Aug 2010 20:47:15 +0900 (JST)
From: Round Robinjp <roundrobinjp@yahoo.co.jp>
Subject: set mem=xxx and then ioremap
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

If I specify mem=xxx and then ioremap the remaining memory,
and then iounmap it, is that memory returned back to the system?

By the way, is there any limit on the size that can be mapped
by ioremap?

Thanks
RR

--------------------------------------
GyaO! - Anime, Dramas, Movies, and Music videos [FREE]
http://pr.mail.yahoo.co.jp/gyao/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
