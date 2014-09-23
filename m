Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 22B026B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 15:40:25 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so1848635wgg.19
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 12:40:24 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id jy9si1849667wid.26.2014.09.23.12.40.23
        for <linux-mm@kvack.org>;
        Tue, 23 Sep 2014 12:40:23 -0700 (PDT)
Date: Tue, 23 Sep 2014 21:40:21 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: [patch] drivers/rtc/rtc-bq32k.c fix warnings I introduced
Message-ID: <20140923194021.GA15840@amd>
References: <542131f8.FeDGKH/9671AZbCt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <542131f8.FeDGKH/9671AZbCt%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, kernel list <linux-kernel@vger.kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, pavel@ucw.cz, rtc-linux@googlegroups.com, dan.carpenter@oracle.com

Sorry about that, I somehow failed to notice rather severe warnings.

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/rtc/rtc-bq32k.c b/drivers/rtc/rtc-bq32k.c
index 4c24fb0..c02e246 100644
--- a/drivers/rtc/rtc-bq32k.c
+++ b/drivers/rtc/rtc-bq32k.c
@@ -132,9 +132,7 @@ static const struct rtc_class_ops bq32k_rtc_ops = {
 
 static int trickle_charger_of_init(struct device *dev, struct device_node *node)
 {
-	int plen = 0;
-	const uint32_t *setup;
-	const uint32_t *reg;
+	unsigned char reg;
 	int error;
 	u32 ohms = 0;
 
@@ -166,7 +164,7 @@ static int trickle_charger_of_init(struct device *dev, struct device_node *node)
 		break;
 
 	default:
-		dev_err(dev, "invalid resistor value (%d)\n", *setup);
+		dev_err(dev, "invalid resistor value (%d)\n", ohms);
 		return -EINVAL;
 	}
 


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
