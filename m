Subject: Re: 2.5.68-mm3
From: steven roemen <sdroemen1@cox.net>
In-Reply-To: <20030429235959.3064d579.akpm@digeo.com>
References: <20030429235959.3064d579.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1051759115.1001.1.camel@lws04.home.net>
Mime-Version: 1.0
Date: 30 Apr 2003 22:18:35 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

i think this has been reported for linus's tree, but i noticed it with
-mm3

Steve

make -f scripts/Makefile.build obj=drivers/ieee1394
  gcc -Wp,-MD,drivers/ieee1394/.nodemgr.o.d -D__KERNEL__ -Iinclude -Wall
-Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common
-pipe -mpreferred-stack-boundary=2 -march=athlon
-Iinclude/asm-i386/mach-default -fomit-frame-pointer -nostdinc
-iwithprefix include    -DKBUILD_BASENAME=nodemgr
-DKBUILD_MODNAME=ieee1394 -c -o drivers/ieee1394/.tmp_nodemgr.o
drivers/ieee1394/nodemgr.c
drivers/ieee1394/nodemgr.c: In function `nodemgr_bus_match':
drivers/ieee1394/nodemgr.c:367: structure has no member named
`class_num'
drivers/ieee1394/nodemgr.c: At top level:
drivers/ieee1394/nodemgr.c:497: unknown field `class_num' specified in
initializer
drivers/ieee1394/nodemgr.c:497: warning: excess elements in struct
initializer
drivers/ieee1394/nodemgr.c:497: warning: (near initialization for
`nodemgr_dev_template_ud')
drivers/ieee1394/nodemgr.c:503: unknown field `class_num' specified in
initializer
drivers/ieee1394/nodemgr.c:503: warning: excess elements in struct
initializer
drivers/ieee1394/nodemgr.c:503: warning: (near initialization for
`nodemgr_dev_template_ne')
drivers/ieee1394/nodemgr.c:508: unknown field `class_num' specified in
initializer
drivers/ieee1394/nodemgr.c:508: warning: initialization makes pointer
from integer without a cast
drivers/ieee1394/nodemgr.c: In function `nodemgr_guid_search_cb':
drivers/ieee1394/nodemgr.c:730: structure has no member named
`class_num'
drivers/ieee1394/nodemgr.c: In function `nodemgr_nodeid_search_cb':
drivers/ieee1394/nodemgr.c:767: structure has no member named
`class_num'
drivers/ieee1394/nodemgr.c: In function `nodemgr_driver_search_cb':
drivers/ieee1394/nodemgr.c:1261: structure has no member named
`class_num'
drivers/ieee1394/nodemgr.c: In function `nodemgr_remove_node':
drivers/ieee1394/nodemgr.c:1449: structure has no member named
`class_num'
make[2]: *** [drivers/ieee1394/nodemgr.o] Error 1
make[1]: *** [drivers/ieee1394] Error 2
make: *** [drivers] Error 2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
