Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8107A6B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 12:40:27 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so9929078wiw.16
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 09:40:26 -0800 (PST)
Received: from mout.web.de (mout.web.de. [212.227.15.14])
        by mx.google.com with ESMTPS id dz1si17274309wib.24.2014.11.17.09.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Nov 2014 09:40:26 -0800 (PST)
Message-ID: <546A3302.9040804@users.sourceforge.net>
Date: Mon, 17 Nov 2014 18:40:18 +0100
From: SF Markus Elfring <elfring@users.sourceforge.net>
MIME-Version: 1.0
Subject: [PATCH 1/1] mm/zswap: Deletion of an unnecessary check before the
 function call "free_percpu"
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.sourceforge.net>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Coccinelle <cocci@systeme.lip6.fr>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Nov 2014 18:33:33 +0100

The free_percpu() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 mm/zswap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index ea064c1..35629f0 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -152,8 +152,7 @@ static int __init zswap_comp_init(void)
 static void zswap_comp_exit(void)
 {
 	/* free percpu transforms */
-	if (zswap_comp_pcpu_tfms)
-		free_percpu(zswap_comp_pcpu_tfms);
+	free_percpu(zswap_comp_pcpu_tfms);
 }
 
 /*********************************
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
