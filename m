Return-Path: <owner-linux-mm@kvack.org>
From: owner-linux-mm@kvack.org
Subject: BOUNCE linux-mm@kvack.org: Header field too long (>2048)
Message-Id: <20130305145804.BFC616B0006@kanga.kvack.org>
Date: Tue,  5 Mar 2013 09:58:04 -0500 (EST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm-approval@kvack.org

>From bcrl@kvack.org  Tue Mar  5 09:58:04 2013
Return-Path: <bcrl@kvack.org>
X-Original-To: int-list-linux-mm@kvack.org
Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E42E6B0007; Tue,  5 Mar 2013 09:58:04 -0500 (EST)
X-Original-To: linux-mm@kvack.org
Delivered-To: linux-mm@kvack.org
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D6E8C6B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:58:03 -0500 (EST)
Received: from mail-pb0-f46.google.com ([209.85.160.46]) (using TLSv1) by na3sys010amx127.postini.com ([74.125.244.10]) with SMTP;
	Tue, 05 Mar 2013 14:58:03 GMT
Received: by mail-pb0-f46.google.com with SMTP id uo15so4521155pbc.5
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:58:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:from:to:cc:subject:date:message-id:x-mailer:in-reply-to
         :references;
        bh=JvgwYTJxADQGPl6rTdYeAlOcQVGHasJT/8OAP0hAyqM=;
        b=Ob7yhp6dZgbAJMiIPpIDfRVtwXo/JXi5+GbrSZN1pKK3vm/kvb+znFG2qLhERPnHjE
         BpDCoQyxi9zsLg22WyUp7Dv3E8LA6mK6nztNHf+dNMAt3T/R4Qt/+ID38dp5u4kC3CUi
         e1S9dr1/+4o5BDYSn6GNRCQKJbmxrlkzaOWzFyxZiNxEJeghL5WsbV4iK2F+XPhMXLjC
         5MkyRgnQPWUNpnrTPCQHEfxf2Cs4aogCUIpJ94rTfltm1ASTPjO49GvMRZgLFQMGYIe/
         Z2GfeMozEBUmSRJqWsIISop2y8tj8a9Q6pkzs5DBadBiUF5KPeao94wr7b3aAA6Z6wZD
         o67w==
X-Received: by 10.68.189.133 with SMTP id gi5mr37078438pbc.129.1362495482729;
        Tue, 05 Mar 2013 06:58:02 -0800 (PST)
Received: from localhost.localdomain ([114.250.86.208])
        by mx.google.com with ESMTPS id rr14sm26970373pbb.34.2013.03.05.06.57.19
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Mar 2013 06:58:01 -0800 (PST)
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
Subject: [RFC PATCH v1 01/33] mm: introduce common help functions to deal with reserved/managed pages
Date: Tue,  5 Mar 2013 22:54:44 +0800
Message-Id: <1362495317-32682-2-git-send-email-jiang.liu@huawei.com>
X-Mailer: git-send-email 1.7.9.5
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
X-pstn-neptune: 0/0/0.00/0
X-pstn-levels:     (S:64.57341/99.90000 CV:99.9000 FC:95.5390 LC:95.5390 R:95.9108 P:95.9108 M:97.0282 C:98.6951 )
X-pstn-dkim: 1 skipped:not-enabled
X-pstn-settings: 3 (1.0000:0.0100) s cv GT3 gt2 gt1 r p m c 
X-pstn-addresses: from <liuj97@gmail.com> [db-null] 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.3

Code to deal with reserved/managed pages are duplicated by many
architectures, so introduce common help functions to reduce duplicated
code. These common help functions will also be used to concentrate code
to modify totalram_pages and zone->managed_pages, which makes the code
much more clear.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 include/linux/mm.h |   37 +++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c    |   20 ++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7acc9dc..881461c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1295,6 +1295,43 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 
+/* Help functions to deal with reserved/managed pages. */
+extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
+					int poison, char *s);
+
+static inline void adjust_managed_page_count(struct page *page, long count)
+{
+	totalram_pages += count;
+}
+
+static inline void __free_reserved_page(struct page *page)
+{
+	ClearPageReserved(page);
+	init_page_count(page);
+	__free_page(page);
+}
+
+static inline void free_reserved_page(struct page *page)
+{
+	__free_reserved_page(page);
+	adjust_managed_page_count(page, 1);
+}
+
+static inline void mark_page_reserved(struct page *page)
+{
+	SetPageReserved(page);
+	adjust_managed_page_count(page, -1);
+}
+
+static inline void free_initmem_default(int poison)
+{
+	extern char __init_begin[], __init_end[];
+
+	free_reserved_area(PAGE_ALIGN((unsigned long)&__init_begin) ,
+			   ((unsigned long)&__init_end) & PAGE_MASK,
+			   poison, "unused kernel");
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /*
  * With CONFIG_HAVE_MEMBLOCK_NODE_MAP set, an architecture may initialise its
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fcced7..0fadb09 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5113,6 +5113,26 @@ early_param("movablecore", cmdline_parse_movablecore);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+unsigned long free_reserved_area(unsigned long start, unsigned long end,
+				 int poison, char *s)
+{
+	unsigned long pages, pos;
+
+	pos = start = PAGE_ALIGN(start);
+	end &= PAGE_MASK;
+	for (pages = 0; pos < end; pos += PAGE_SIZE, pages++) {
+		if (poison)
+			memset((void *)pos, poison, PAGE_SIZE);
+		free_reserved_page(virt_to_page(pos));
+	}
+
+	if (pages && s)
+		pr_info("Freeing %s memory: %ldK (%lx - %lx)\n",
+			s, pages << (PAGE_SHIFT - 10), start, end);
+
+	return pages;
+}
+
 /**
  * set_dma_reserve - set the specified number of pages reserved in the first zone
  * @new_dma_reserve: The number of pages to mark reserved
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
