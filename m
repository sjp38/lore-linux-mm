Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 0A1E86B0068
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 08:58:04 -0400 (EDT)
Date: Mon, 10 Sep 2012 20:57:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [glommer-memcg:kmemcg-slab 57/62] drivers/video/riva/fbdev.c:281:9:
 sparse: preprocessor token MAX_LEVEL redefined
Message-ID: <20120910125759.GA11808@localhost>
References: <20120910111638.GC9660@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120910111638.GC9660@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

Glauber,

The patch entitled

 sl[au]b: Allocate objects from memcg cache

changes

 include/linux/slub_def.h |   15 ++++++++++-----

which triggers this warning:

drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined

It's the MAX_LEVEL that is defined in include/linux/idr.h.

MAX_LEVEL is obviously too generic. Better adding some prefix to it?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
