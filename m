Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFDC36B0332
	for <linux-mm@kvack.org>; Wed, 16 May 2018 10:18:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c56-v6so737146wrc.5
        for <linux-mm@kvack.org>; Wed, 16 May 2018 07:18:59 -0700 (PDT)
Received: from www.linuxtv.org (www.linuxtv.org. [130.149.80.248])
        by mx.google.com with ESMTPS id k27-v6si381254eda.213.2018.05.16.07.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 07:18:58 -0700 (PDT)
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Date: Mon, 14 May 2018 11:18:19 +0000
Subject: [git:media_tree/master] media: gp8psk: don't abuse of GFP_DMA
Reply-to: linux-media@vger.kernel.org
Message-Id: <E1fIxGa-0001wj-8z@www.linuxtv.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxtv-commits@linuxtv.org
Cc: linux-mm@kvack.org, "Luis R. Rodriguez" <mcgrof@kernel.org>

This is an automatic generated email to let you know that the following patch were queued:

Subject: media: gp8psk: don't abuse of GFP_DMA
Author:  Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Date:    Sat May 5 12:09:46 2018 -0400

There's s no reason why it should be using GFP_DMA there.
This is an USB driver. Any restriction should be, instead,
at HCI core, if any.

Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

 drivers/media/usb/dvb-usb/gp8psk.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

---

diff --git a/drivers/media/usb/dvb-usb/gp8psk.c b/drivers/media/usb/dvb-usb/gp8psk.c
index 37f062225ed2..334b9fb98112 100644
--- a/drivers/media/usb/dvb-usb/gp8psk.c
+++ b/drivers/media/usb/dvb-usb/gp8psk.c
@@ -148,7 +148,7 @@ static int gp8psk_load_bcm4500fw(struct dvb_usb_device *d)
 	info("downloading bcm4500 firmware from file '%s'",bcm4500_firmware);
 
 	ptr = fw->data;
-	buf = kmalloc(64, GFP_KERNEL | GFP_DMA);
+	buf = kmalloc(64, GFP_KERNEL);
 	if (!buf) {
 		ret = -ENOMEM;
 		goto out_rel_fw;
