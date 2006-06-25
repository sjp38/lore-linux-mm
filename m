Received: by py-out-1112.google.com with SMTP id m51so1124167pye
        for <linux-mm@kvack.org>; Sun, 25 Jun 2006 10:26:42 -0700 (PDT)
Message-ID: <6bffcb0e0606251026gbd121dam83c1b763b8cba02d@mail.gmail.com>
Date: Sun, 25 Jun 2006 19:26:42 +0200
From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [patch] 2.6.17: lockless pagecache
In-Reply-To: <20060625163930.GB3006@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060625163930.GB3006@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On 25/06/06, Nick Piggin <npiggin@suse.de> wrote:
> Updated lockless pagecache patchset available here:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/npiggin/patches/lockless/2.6.17/lockless.patch.gz
>

"make O=/dir oldconfig" doesn't work.

[michal@ltg01-fedora linux-work]$ LANG="C" make O=../linux-work-obj/ oldconfig
  GEN     /usr/src/linux-work-obj/Makefile
  HOSTCC  scripts/kconfig/zconf.tab.o
In file included from scripts/kconfig/zconf.tab.c:158:
scripts/kconfig/zconf.hash.c: In function 'kconf_id_lookup':
scripts/kconfig/zconf.hash.c:190: error: 'T_OPT_DEFCONFIG_LIST'
undeclared (first use in this function)
scripts/kconfig/zconf.hash.c:190: error: (Each undeclared identifier
is reported only once
scripts/kconfig/zconf.hash.c:190: error: for each function it appears in.)
scripts/kconfig/zconf.hash.c:190: error: 'TF_OPTION' undeclared (first
use in this function)
scripts/kconfig/zconf.hash.c:203: error: 'T_OPT_MODULES' undeclared
(first use in this function)
scripts/kconfig/zconf.tab.c: In function 'zconfparse':
scripts/kconfig/zconf.tab.c:1557: error: 'TF_OPTION' undeclared (first
use in this function)
scripts/kconfig/zconf.tab.c:1557: error: invalid operands to binary &
scripts/kconfig/zconf.tab.c:1558: warning: implicit declaration of
function 'menu_add_option'
make[2]: *** [scripts/kconfig/zconf.tab.o] Error 1
make[1]: *** [oldconfig] Error 2
make: *** [oldconfig] Error 2

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
