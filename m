Date: Fri, 18 Apr 2003 09:24:54 -0700
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: 2.5.67-mm4 devfs don't compile
Message-Id: <20030418092454.6b9aa705.rddunlap@osdl.org>
In-Reply-To: <20030418161732.GA14198@hh.idb.hist.no>
References: <20030418014536.79d16076.akpm@digeo.com>
	<20030418161732.GA14198@hh.idb.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Apr 2003 18:17:32 +0200 Helge Hafting <helgehaf@aitel.hist.no> wrote:

| I'd like to try mm4 and see how AS runs on scsi, but
| I got a compile error in devfs:
| 
|   gcc -Wp,-MD,fs/devfs/.base.o.d -D__KERNEL__ -Iinclude -Wall 
| -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common -pipe 
| -mpreferred-stack-boundary=2 -march=pentium2 -Iinclude/asm-i386/mach-default 
| -fomit-frame-pointer -nostdinc -iwithprefix include    -DKBUILD_BASENAME=base 
| -DKBUILD_MODNAME=devfs -c -o fs/devfs/base.o fs/devfs/base.c
| fs/devfs/base.c: In function `devfsd_notify':
| fs/devfs/base.c:1426: too many arguments to function `devfsd_notify_de'
| fs/devfs/base.c: In function `devfs_register':
| fs/devfs/base.c:1460: warning: too few arguments for format
| fs/devfs/base.c:1460: warning: too few arguments for format
| make[2]: *** [fs/devfs/base.o] Error 1
| make[1]: *** [fs/devfs] Error 2
| make: *** [fs] Error 2

Hi,

Please look at today's email archives.  I've seen at least 2 patches
posted to fix this.

--
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
