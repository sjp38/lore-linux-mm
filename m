Return-Path: <owner-linux-mm@kvack.org>
From: owner-linux-mm@kvack.org
Subject: BOUNCE linux-mm@kvack.org: Header field too long (>2048)
Message-Id: <20130305145721.F31226B0006@kanga.kvack.org>
Date: Tue,  5 Mar 2013 09:57:21 -0500 (EST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm-approval@kvack.org

>From bcrl@kvack.org  Tue Mar  5 09:57:21 2013
Return-Path: <bcrl@kvack.org>
X-Original-To: int-list-linux-mm@kvack.org
Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D47C16B0007; Tue,  5 Mar 2013 09:57:21 -0500 (EST)
X-Original-To: linux-mm@kvack.org
Delivered-To: linux-mm@kvack.org
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 435F86B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:57:21 -0500 (EST)
Received: from mail-pb0-f50.google.com ([209.85.160.50]) (using TLSv1) by na3sys010amx197.postini.com ([74.125.244.10]) with SMTP;
	Tue, 05 Mar 2013 14:57:21 GMT
Received: by mail-pb0-f50.google.com with SMTP id up1so4557255pbc.37
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:57:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:from:to:cc:subject:date:message-id:x-mailer;
        bh=C/LbATEuMTxceHeqCfbtow+CB/E+oDOEhyeAFqIWm9I=;
        b=a8/7mbTxaRDmm6gNiEm1jh8OIevsWhIrY7WvWBp5an07HtF/slqFrNNFeNFbtEa3mh
         sgl9uBuJh11vsZ6Q1PJX3r4NmQIWOakzqSQphdDwFeRtteiKdVNPo2ygLUCQ8UI6bzZ5
         yBBlyz9lpYXNAcGRBVDBPXna0fftrn/qd1QMT3cmBgnXVKIS8y7liGZGSUgFZdwQ3Ue8
         D+CbquEsWiflmdQWhLDmjJUrduN4soafK4aQi5L3fL/barf+ZzyqxpoeCxdXuJfdMYCH
         XEfiGJ6EVVzl1aZ1KBQr/qXVfVtYFcmovXGiwLp7WZcmDfPb4DTMmPP9ivBUFhR8ZN2V
         HaCQ==
X-Received: by 10.68.225.99 with SMTP id rj3mr38573293pbc.183.1362495438727;
        Tue, 05 Mar 2013 06:57:18 -0800 (PST)
Received: from localhost.localdomain ([114.250.86.208])
        by mx.google.com with ESMTPS id rr14sm26970373pbb.34.2013.03.05.06.56.41
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Mar 2013 06:57:17 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>,
	Wen Congyang <wency@cn.fujitsu.com>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Chris Clayton <chris2553@googlemail.com>,
	"Rafael J . Wysocki" <rjw@sisk.pl>,
	Mel Gorman <mgorman@suse.de>,
	Minchan Kim <minchan@kernel.org>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Michal Hocko <mhocko@suse.cz>,
	Jianguo Wu <wujianguo@huawei.com>,
	Anatolij Gustschin <agust@denx.de>,
	Aurelien Jacquiot <a-jacquiot@ti.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Chen Liqin <liqin.chen@sunplusct.com>,
	Chris Metcalf <cmetcalf@tilera.com>,
	Chris Zankel <chris@zankel.net>,
	David Howells <dhowells@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biederman <ebiederm@xmission.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Guan Xuetao <gxt@mprc.pku.edu.cn>,
	Haavard Skinnemoen <hskinnemoen@gmail.com>,
	Hans-Christian Egtvedt <egtvedt@samfundet.no>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Helge Deller <deller@gmx.de>,
	Hirokazu Takata <takata@linux-m32r.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	Jeff Dike <jdike@addtoit.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Jonas Bonn <jonas@southpole.se>,
	Koichi Yasutake <yasutake.koichi@jp.panasonic.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Lennox Wu <lennox.wu@gmail.com>,
	Mark Salter <msalter@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Matt Turner <mattst88@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Michal Simek <monstr@monstr.eu>,
	Michel Lespinasse <walken@google.com>,
	Mikael Starvik <starvik@axis.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Paul Mundt <lethal@linux-sh.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Richard Henderson <rth@twiddle.net>,
	Rik van Riel <riel@redhat.com>,
	Russell King <linux@arm.linux.org.uk>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Sam Ravnborg <sam@ravnborg.org>,
	Tang Chen <tangchen@cn.fujitsu.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tony Luck <tony.luck@intel.com>,
	Will Deacon <will.deacon@arm.com>,
	Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>,
	Yinghai Lu <yinghai@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	x86@kernel.org,
	xen-devel@lists.xensource.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	virtualization@lists.linux-foundation.org
Subject: [RFC PATCH v1 00/33] accurately calculate pages managed by buddy system
Date: Tue,  5 Mar 2013 22:54:43 +0800
Message-Id: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
X-Mailer: git-send-email 1.7.9.5
X-pstn-neptune: 0/0/0.00/0
X-pstn-levels:     (S:36.81945/99.90000 CV:99.9000 FC:93.6803 LC:95.5390 R:95.9108 P:95.9108 M:97.0282 C:98.6951 )
X-pstn-dkim: 1 skipped:not-enabled
X-pstn-settings: 3 (1.0000:0.0100) s cv GT3 gt2 gt1 r p m c 
X-pstn-addresses: from <liuj97@gmail.com> [db-null] 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.3

The original goal of this patchset is to fix the bug reported by
https://bugzilla.kernel.org/show_bug.cgi?id=53501

Now it has also been expanded to reduce common code used by memory
initializion. In total it has reduced about 550 lines of code.

Patch 1:
	Extract common help functions from free_init_mem() and
	free_initrd_mem() on different architectures.
Patch 2-27:
	Use help functions to simplify free_init_mem() and
	free_initrd_mem() on different architectures. This has reduced
	about 500 lines of code.
Patch 28:
	Introduce common help function to free highmem pages when
	initializing memory subsystem.
Patch 29-32:
	Adjust totalhigh_pages, totalram_pages and zone->managed_pages
	altogether when reserving/unreserving pages.
Patch 33:
	Change /sys/.../node/nodex/meminfo to report available pages
	within the node as "MemTotal".

We have only tested these patchset on x86 platforms, and have done basic
compliation tests using cross-compilers from ftp.kernel.org. That means
some code may not pass compilation on some architectures. So any help
to test this patchset are welcomed!

Jiang Liu (33):
  mm: introduce common help functions to deal with reserved/managed
    pages
  mm/alpha: use common help functions to free reserved pages
  mm/ARM: use common help functions to free reserved pages
  mm/avr32: use common help functions to free reserved pages
  mm/blackfin: use common help functions to free reserved pages
  mm/c6x: use common help functions to free reserved pages
  mm/cris: use common help functions to free reserved pages
  mm/FRV: use common help functions to free reserved pages
  mm/h8300: use common help functions to free reserved pages
  mm/IA64: use common help functions to free reserved pages
  mm/m32r: use common help functions to free reserved pages
  mm/m68k: use common help functions to free reserved pages
  mm/microblaze: use common help functions to free reserved pages
  mm/MIPS: use common help functions to free reserved pages
  mm/mn10300: use common help functions to free reserved pages
  mm/openrisc: use common help functions to free reserved pages
  mm/parisc: use common help functions to free reserved pages
  mm/ppc: use common help functions to free reserved pages
  mm/s390: use common help functions to free reserved pages
  mm/score: use common help functions to free reserved pages
  mm/SH: use common help functions to free reserved pages
  mm/SPARC: use common help functions to free reserved pages
  mm/um: use common help functions to free reserved pages
  mm/unicore32: use common help functions to free reserved pages
  mm/x86: use common help functions to free reserved pages
  mm/xtensa: use common help functions to free reserved pages
  mm,kexec: use common help functions to free reserved pages
  mm: introduce free_highmem_page() helper to free highmem pages inti
    buddy system
  mm: accurately calculate zone->managed_pages for highmem zones
  mm: use a dedicated lock to protect totalram_pages and
    zone->managed_pages
  mm: avoid using __free_pages_bootmem() at runtime
  mm: correctly update zone->mamaged_pages
  mm: report available pages as "MemTotal" for each NUMA node

 arch/alpha/kernel/sys_nautilus.c             |    5 +-
 arch/alpha/mm/init.c                         |   24 ++-------
 arch/alpha/mm/numa.c                         |    3 +-
 arch/arm/mm/init.c                           |   46 ++++++-----------
 arch/arm64/mm/init.c                         |   26 +---------
 arch/avr32/mm/init.c                         |   24 +--------
 arch/blackfin/mm/init.c                      |   20 +-------
 arch/c6x/mm/init.c                           |   30 +----------
 arch/cris/mm/init.c                          |   16 +-----
 arch/frv/mm/init.c                           |   32 ++----------
 arch/h8300/mm/init.c                         |   28 +----------
 arch/ia64/mm/init.c                          |   23 ++-------
 arch/m32r/mm/init.c                          |   26 ++--------
 arch/m68k/mm/init.c                          |   24 +--------
 arch/microblaze/include/asm/setup.h          |    1 -
 arch/microblaze/mm/init.c                    |   33 ++----------
 arch/mips/mm/init.c                          |   36 ++++----------
 arch/mips/sgi-ip27/ip27-memory.c             |    4 +-
 arch/mn10300/mm/init.c                       |   23 +--------
 arch/openrisc/mm/init.c                      |   27 ++--------
 arch/parisc/mm/init.c                        |   24 ++-------
 arch/powerpc/kernel/crash_dump.c             |    5 +-
 arch/powerpc/kernel/fadump.c                 |    5 +-
 arch/powerpc/kernel/kvm.c                    |    7 +--
 arch/powerpc/mm/mem.c                        |   34 ++-----------
 arch/powerpc/platforms/512x/mpc512x_shared.c |    5 +-
 arch/s390/mm/init.c                          |   35 +++----------
 arch/score/mm/init.c                         |   33 ++----------
 arch/sh/mm/init.c                            |   26 ++--------
 arch/sparc/kernel/leon_smp.c                 |   15 ++----
 arch/sparc/mm/init_32.c                      |   50 +++----------------
 arch/sparc/mm/init_64.c                      |   25 ++--------
 arch/tile/mm/init.c                          |    4 +-
 arch/um/kernel/mem.c                         |   25 ++--------
 arch/unicore32/mm/init.c                     |   26 +---------
 arch/x86/mm/init.c                           |    5 +-
 arch/x86/mm/init_32.c                        |   10 +---
 arch/x86/mm/init_64.c                        |   18 +------
 arch/xtensa/mm/init.c                        |   21 ++------
 drivers/virtio/virtio_balloon.c              |    8 +--
 drivers/xen/balloon.c                        |   19 ++-----
 include/linux/mm.h                           |   36 ++++++++++++++
 include/linux/mmzone.h                       |   14 ++++--
 kernel/kexec.c                               |    8 +--
 mm/bootmem.c                                 |   16 ++----
 mm/hugetlb.c                                 |    2 +-
 mm/memory_hotplug.c                          |   31 ++----------
 mm/nobootmem.c                               |   14 ++----
 mm/page_alloc.c                              |   69 ++++++++++++++++++++++----
 49 files changed, 248 insertions(+), 793 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
