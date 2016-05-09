Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6E56B025F
	for <linux-mm@kvack.org>; Mon,  9 May 2016 07:39:44 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id aq1so383709715obc.2
        for <linux-mm@kvack.org>; Mon, 09 May 2016 04:39:44 -0700 (PDT)
Received: from relmlie2.idc.renesas.com (relmlor3.renesas.com. [210.160.252.173])
        by mx.google.com with ESMTP id 206si32524630iou.198.2016.05.09.04.39.42
        for <linux-mm@kvack.org>;
        Mon, 09 May 2016 04:39:43 -0700 (PDT)
From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: About lazy_max_pages()
Date: Mon, 9 May 2016 11:39:36 +0000
Message-ID: <SG2PR06MB091917A090460AEBEFF339E1D8700@SG2PR06MB0919.apcprd06.prod.outlook.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-renesas-soc@vger.kernel.org" <linux-renesas-soc@vger.kernel.org>

Hi,

I have a question about (1) in the following RFC:
http://www.spinics.net/lists/linux-rt-users/msg15082.html

Does Upstream accept such a patch?

< Overview >
My environment (v4.6-rc5 on arm64 / r8a7795) has similar situation
when dma_free_coherent() is called.

< For example (The buffer size is 1024 bytes.) >
 - Sometimes the function spends about 8 msecs (worst-case).
 - If I modified the value such the patch, sometimes the spend time is abou=
t 1 msecs (worst-case).

So, I would like to know that upstream accepts such a patch.

< Remarks >
I also tried both the (1) and (2) patches on my environment.
However, kernel stopped on the way.

Best regards,
Yoshihiro Shimoda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
