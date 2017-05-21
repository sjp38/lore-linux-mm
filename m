Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D56CF280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 04:39:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k15so127496wmh.3
        for <linux-mm@kvack.org>; Sun, 21 May 2017 01:39:17 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.12])
        by mx.google.com with ESMTPS id c74si17946253wmc.161.2017.05.21.01.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 01:39:16 -0700 (PDT)
Subject: [PATCH 2/3] zswap: Improve a size determination in
 zswap_frontswap_init()
From: SF Markus Elfring <elfring@users.sourceforge.net>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
Message-ID: <19f9da22-092b-f867-bdf6-f4dbad7ccf1f@users.sourceforge.net>
Date: Sun, 21 May 2017 10:26:22 +0200
MIME-Version: 1.0
In-Reply-To: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 May 2017 22:44:03 +0200

Replace the specification of a data structure by a pointer dereference
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 mm/zswap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 18d8e87119a6..a6e67633be03 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1156,5 +1156,5 @@ static void zswap_frontswap_init(unsigned type)
 {
 	struct zswap_tree *tree;
 
-	tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
+	tree = kzalloc(sizeof(*tree), GFP_KERNEL);
 	if (!tree) {
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
