Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 64A276B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 07:16:18 -0400 (EDT)
Date: Wed, 5 Jun 2013 13:16:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: mmots: mm-correctly-update-zone-managed_pages-fix.patch breaks
 compilation
Message-ID: <20130605111607.GM15997@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "Michael S. Tsirkin" <mst@redhat.com>, sworddragon2@aol.com, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ingo Molnar <mingo@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jiang Liu <jiang.liu@huawei.com>, Jiang Liu <liuj97@gmail.com>, Jianguo Wu <wujianguo@huawei.com>, Joonsoo Kim <js1304@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <rmk@arm.linux.org.uk>, Rusty Russell <rusty@rustcorp.com.au>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Wen Congyang <wency@cn.fujitsu.com>, Will Deacon <will.deacon@arm.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
the above patch breaks compilation:
mm/page_alloc.c: In function a??adjust_managed_page_counta??:
mm/page_alloc.c:5226: error: lvalue required as left operand of assignment

Could you drop the mm/page_alloc.c hunk, please? Not all versions of gcc
are able to cope with this obviously (mine is 4.3.4).

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
