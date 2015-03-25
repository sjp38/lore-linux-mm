Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5E58C6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:30:29 -0400 (EDT)
Received: by pagj7 with SMTP id j7so26143734pag.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 04:30:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id xd14si3232194pac.211.2015.03.25.04.30.27
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 04:30:27 -0700 (PDT)
From: Javi Merino <javi.merino@arm.com>
Subject: [PATCH] ASoC: pcm512x: use DIV_ROUND_CLOSEST_ULL() from kernel.h
Date: Wed, 25 Mar 2015 11:29:44 +0000
Message-Id: <1427282984-29296-1-git-send-email-javi.merino@arm.com>
In-Reply-To: <201503250933.dBZIxVT3%fengguang.wu@intel.com>
References: <201503250933.dBZIxVT3%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Javi Merino <javi.merino@arm.com>, Peter Rosin <peda@axentia.se>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>

Now that the kernel provides DIV_ROUND_CLOSEST_ULL(), drop the internal
implementation and use the kernel one.

Cc: Peter Rosin <peda@axentia.se>
Cc: Mark Brown <broonie@kernel.org>
Cc: Liam Girdwood <lgirdwood@gmail.com>
Cc: Jaroslav Kysela <perex@perex.cz>
Cc: Takashi Iwai <tiwai@suse.de>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Javi Merino <javi.merino@arm.com>
---
Patches in the -mm tree now provide a DIV_ROUND_CLOSEST_ULL()
implementation in kernel.h[0].  If I understand it correctly, this
patch should go via the -mm tree as well with appropriate Acks from
the maintainers.

[0] http://ozlabs.org/~akpm/mmots/broken-out/kernelh-implement-div_round_closest_ull.patch

 sound/soc/codecs/pcm512x.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/sound/soc/codecs/pcm512x.c b/sound/soc/codecs/pcm512x.c
index 9974f201a08f..a3dad00b5afc 100644
--- a/sound/soc/codecs/pcm512x.c
+++ b/sound/soc/codecs/pcm512x.c
@@ -18,6 +18,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/clk.h>
+#include <linux/kernel.h>
 #include <linux/pm_runtime.h>
 #include <linux/regmap.h>
 #include <linux/regulator/consumer.h>
@@ -31,8 +32,6 @@
 
 #define DIV_ROUND_DOWN_ULL(ll, d) \
 	({ unsigned long long _tmp = (ll); do_div(_tmp, d); _tmp; })
-#define DIV_ROUND_CLOSEST_ULL(ll, d) \
-	({ unsigned long long _tmp = (ll)+(d)/2; do_div(_tmp, d); _tmp; })
 
 #define PCM512x_NUM_SUPPLIES 3
 static const char * const pcm512x_supply_names[PCM512x_NUM_SUPPLIES] = {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
