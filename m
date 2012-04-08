Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 69F3F6B004D
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 19:38:28 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so4000567bkw.14
        for <linux-mm@kvack.org>; Sun, 08 Apr 2012 16:38:27 -0700 (PDT)
Date: Mon, 9 Apr 2012 03:38:20 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 2/3] vmevent-test: No need for SDL library
Message-ID: <20120408233820.GB4839@panacea>
References: <20120408233550.GA3791@panacea>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120408233550.GA3791@panacea>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

panacea:~/src/linux/linux-vmevent/tools/testing/vmevent$ make
cc -O3 -g -std=gnu99 -Wcast-align -Wformat -Wformat-security
-Wformat-y2k -Wshadow -Winit-self -Wpacked -Wredundant-decls
-Wstrict-aliasing=3 -Wswitch-default -Wno-system-headers -Wundef
-Wwrite-strings -Wbad-function-cast -Wmissing-declarations
-Wmissing-prototypes -Wnested-externs -Wold-style-definition
-Wstrict-prototypes -Wdeclaration-after-statement  -lSDL  vmevent-test.c
-o vmevent-test
/usr/bin/ld: cannot find -lSDL
collect2: ld returned 1 exit status
make: *** [vmevent-test] Error 1

This patch fixes the issue.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 tools/testing/vmevent/Makefile |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/testing/vmevent/Makefile b/tools/testing/vmevent/Makefile
index 5b5505f..d14b5c9 100644
--- a/tools/testing/vmevent/Makefile
+++ b/tools/testing/vmevent/Makefile
@@ -20,7 +20,6 @@ WARNINGS += -Wstrict-prototypes
 WARNINGS += -Wdeclaration-after-statement
 
 CFLAGS  = -O3 -g -std=gnu99 $(WARNINGS)
-LDFLAGS = -lSDL
 
 PROGRAMS = vmevent-test
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
