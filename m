Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 9C7C56B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 01:26:26 -0500 (EST)
Message-ID: <513832F0.30504@synopsys.com>
Date: Thu, 7 Mar 2013 11:55:52 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v1 00/33] accurately calculate pages managed by buddy
 system
References: <51376444.9030601@gmail.com>
In-Reply-To: <51376444.9030601@gmail.com>
Content-Type: multipart/mixed;
	boundary="------------040600030405000409030405"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: James Hogan <james.hogan@imgtec.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

--------------040600030405000409030405
Content-Type: multipart/alternative;
	boundary="------------060000040705080005090009"

--------------060000040705080005090009
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

Somehow the CC to linux-arch and linux-mm got lost in the trail - Also adding
James for metag and clipped the extended CC list.

Acked-by: Vineet Gupta <vgupta@synopsys.com> for patch 01 (ARC bits)


-------- Original Message --------
Subject: 	Re: [RFC PATCH v1 00/33] accurately calculate pages managed by buddy system
Date: 	Wed, 6 Mar 2013 23:44:04 +0800
From: 	Jiang Liu <liuj97@gmail.com>
To: 	Vineet Gupta <Vineet.Gupta1@synopsys.com>
CC: 	Andrew Morton <akpm@linux-foundation.org>, David Rientjes
<rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang
<wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, "Chris Clayton"
<chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, "Mel Gorman"
<mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "KAMEZAWA Hiroyuki"
<kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu
<wujianguo@huawei.com>, Anatolij Gustschin <agust@denx.de>, Aurelien Jacquiot
<a-jacquiot@ti.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin
Marinas <catalin.marinas@arm.com>, "Chen Liqin" <liqin.chen@sunplusct.com>, Chris
Metcalf <cmetcalf@tilera.com>, Chris Zankel <chris@zankel.net>, David Howells
<dhowells@redhat.com>, "David S. Miller" <davem@davemloft.net>, Eric Biederman
<ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, "Geert Uytterhoeven"
<geert@linux-m68k.org>



On 03/06/2013 01:21 PM, Vineet Gupta wrote:
> Hi Jiang,
> 
> On Tuesday 05 March 2013 08:24 PM, Jiang Liu wrote:
>> The original goal of this patchset is to fix the bug reported by
>> https://bugzilla.kernel.org/show_bug.cgi?id=53501
>>
>> Now it has also been expanded to reduce common code used by memory
>> initializion. In total it has reduced about 550 lines of code.
>>
>> Patch 1:
>> 	Extract common help functions from free_init_mem() and
>> 	free_initrd_mem() on different architectures.
>> Patch 2-27:
>> 	Use help functions to simplify free_init_mem() and
>> 	free_initrd_mem() on different architectures. This has reduced
>> 	about 500 lines of code.
>> Patch 28:
>> 	Introduce common help function to free highmem pages when
>> 	initializing memory subsystem.
>> Patch 29-32:
>> 	Adjust totalhigh_pages, totalram_pages and zone->managed_pages
>> 	altogether when reserving/unreserving pages.
>> Patch 33:
>> 	Change /sys/.../node/nodex/meminfo to report available pages
>> 	within the node as "MemTotal".
>>
>> We have only tested these patchset on x86 platforms, and have done basic
>> compliation tests using cross-compilers from ftp.kernel.org. That means
>> some code may not pass compilation on some architectures. So any help
>> to test this patchset are welcomed!
>>
>> Jiang Liu (33):
>>   mm: introduce common help functions to deal with reserved/managed
>>     pages
>>   mm/alpha: use common help functions to free reserved pages
>>   mm/ARM: use common help functions to free reserved pages
>>   mm/avr32: use common help functions to free reserved pages
>>   mm/blackfin: use common help functions to free reserved pages
>>   mm/c6x: use common help functions to free reserved pages
>>   mm/cris: use common help functions to free reserved pages
>>   mm/FRV: use common help functions to free reserved pages
>>   mm/h8300: use common help functions to free reserved pages
>>   mm/IA64: use common help functions to free reserved pages
>>   mm/m32r: use common help functions to free reserved pages
>>   mm/m68k: use common help functions to free reserved pages
>>   mm/microblaze: use common help functions to free reserved pages
>>   mm/MIPS: use common help functions to free reserved pages
>>   mm/mn10300: use common help functions to free reserved pages
>>   mm/openrisc: use common help functions to free reserved pages
>>   mm/parisc: use common help functions to free reserved pages
>>   mm/ppc: use common help functions to free reserved pages
>>   mm/s390: use common help functions to free reserved pages
>>   mm/score: use common help functions to free reserved pages
>>   mm/SH: use common help functions to free reserved pages
>>   mm/SPARC: use common help functions to free reserved pages
>>   mm/um: use common help functions to free reserved pages
>>   mm/unicore32: use common help functions to free reserved pages
>>   mm/x86: use common help functions to free reserved pages
>>   mm/xtensa: use common help functions to free reserved pages
>>   mm,kexec: use common help functions to free reserved pages
>>   mm: introduce free_highmem_page() helper to free highmem pages inti
>>     buddy system
>>   mm: accurately calculate zone->managed_pages for highmem zones
>>   mm: use a dedicated lock to protect totalram_pages and
>>     zone->managed_pages
>>   mm: avoid using __free_pages_bootmem() at runtime
>>   mm: correctly update zone->mamaged_pages
>>   mm: report available pages as "MemTotal" for each NUMA node
> 
> I'm not sure what baseline your patches are based off of - however as part of
> 3.9-rc1, two new architectures were merged (arc and metag). It would be ideal if
> they got updated them as part of this series itself - if possible. Please let me know.
> 
> Thx,
> -Vineet

Hi Vineet,
	I have rebased the patchset to v3.9-rc1, but haven't noticed these two
new architectures. So how about the attached three patches?
	Regards!
	Gerry








--------------060000040705080005090009
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    Somehow the CC to linux-arch and linux-mm got lost in the trail -
    Also adding James for metag and clipped the extended CC list.<br>
    <div class="moz-forward-container"><br>
      <pre>Acked-by: Vineet Gupta <a class="moz-txt-link-rfc2396E" href="mailto:vgupta@synopsys.com">&lt;vgupta@synopsys.com&gt;</a> for patch 01 (ARC bits)</pre>
      <br>
      -------- Original Message --------
      <table class="moz-email-headers-table" border="0" cellpadding="0"
        cellspacing="0">
        <tbody>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">Subject:
            </th>
            <td>Re: [RFC PATCH v1 00/33] accurately calculate pages
              managed by buddy system</td>
          </tr>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">Date: </th>
            <td>Wed, 6 Mar 2013 23:44:04 +0800</td>
          </tr>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">From: </th>
            <td>Jiang Liu <a class="moz-txt-link-rfc2396E" href="mailto:liuj97@gmail.com">&lt;liuj97@gmail.com&gt;</a></td>
          </tr>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">To: </th>
            <td>Vineet Gupta <a class="moz-txt-link-rfc2396E" href="mailto:Vineet.Gupta1@synopsys.com">&lt;Vineet.Gupta1@synopsys.com&gt;</a></td>
          </tr>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">CC: </th>
            <td>Andrew Morton <a class="moz-txt-link-rfc2396E" href="mailto:akpm@linux-foundation.org">&lt;akpm@linux-foundation.org&gt;</a>, David
              Rientjes <a class="moz-txt-link-rfc2396E" href="mailto:rientjes@google.com">&lt;rientjes@google.com&gt;</a>, Jiang Liu
              <a class="moz-txt-link-rfc2396E" href="mailto:jiang.liu@huawei.com">&lt;jiang.liu@huawei.com&gt;</a>, Wen Congyang
              <a class="moz-txt-link-rfc2396E" href="mailto:wency@cn.fujitsu.com">&lt;wency@cn.fujitsu.com&gt;</a>, Maciej Rutecki
              <a class="moz-txt-link-rfc2396E" href="mailto:maciej.rutecki@gmail.com">&lt;maciej.rutecki@gmail.com&gt;</a>, "Chris Clayton"
              <a class="moz-txt-link-rfc2396E" href="mailto:chris2553@googlemail.com">&lt;chris2553@googlemail.com&gt;</a>, "Rafael J . Wysocki"
              <a class="moz-txt-link-rfc2396E" href="mailto:rjw@sisk.pl">&lt;rjw@sisk.pl&gt;</a>, "Mel Gorman" <a class="moz-txt-link-rfc2396E" href="mailto:mgorman@suse.de">&lt;mgorman@suse.de&gt;</a>,
              Minchan Kim <a class="moz-txt-link-rfc2396E" href="mailto:minchan@kernel.org">&lt;minchan@kernel.org&gt;</a>, "KAMEZAWA
              Hiroyuki" <a class="moz-txt-link-rfc2396E" href="mailto:kamezawa.hiroyu@jp.fujitsu.com">&lt;kamezawa.hiroyu@jp.fujitsu.com&gt;</a>, Michal
              Hocko <a class="moz-txt-link-rfc2396E" href="mailto:mhocko@suse.cz">&lt;mhocko@suse.cz&gt;</a>, Jianguo Wu
              <a class="moz-txt-link-rfc2396E" href="mailto:wujianguo@huawei.com">&lt;wujianguo@huawei.com&gt;</a>, Anatolij Gustschin
              <a class="moz-txt-link-rfc2396E" href="mailto:agust@denx.de">&lt;agust@denx.de&gt;</a>, Aurelien Jacquiot
              <a class="moz-txt-link-rfc2396E" href="mailto:a-jacquiot@ti.com">&lt;a-jacquiot@ti.com&gt;</a>, Benjamin Herrenschmidt
              <a class="moz-txt-link-rfc2396E" href="mailto:benh@kernel.crashing.org">&lt;benh@kernel.crashing.org&gt;</a>, Catalin Marinas
              <a class="moz-txt-link-rfc2396E" href="mailto:catalin.marinas@arm.com">&lt;catalin.marinas@arm.com&gt;</a>, "Chen Liqin"
              <a class="moz-txt-link-rfc2396E" href="mailto:liqin.chen@sunplusct.com">&lt;liqin.chen@sunplusct.com&gt;</a>, Chris Metcalf
              <a class="moz-txt-link-rfc2396E" href="mailto:cmetcalf@tilera.com">&lt;cmetcalf@tilera.com&gt;</a>, Chris Zankel
              <a class="moz-txt-link-rfc2396E" href="mailto:chris@zankel.net">&lt;chris@zankel.net&gt;</a>, David Howells
              <a class="moz-txt-link-rfc2396E" href="mailto:dhowells@redhat.com">&lt;dhowells@redhat.com&gt;</a>, "David S. Miller"
              <a class="moz-txt-link-rfc2396E" href="mailto:davem@davemloft.net">&lt;davem@davemloft.net&gt;</a>, Eric Biederman
              <a class="moz-txt-link-rfc2396E" href="mailto:ebiederm@xmission.com">&lt;ebiederm@xmission.com&gt;</a>, Fenghua Yu
              <a class="moz-txt-link-rfc2396E" href="mailto:fenghua.yu@intel.com">&lt;fenghua.yu@intel.com&gt;</a>, "Geert Uytterhoeven"
              <a class="moz-txt-link-rfc2396E" href="mailto:geert@linux-m68k.org">&lt;geert@linux-m68k.org&gt;</a></td>
          </tr>
        </tbody>
      </table>
      <br>
      <br>
      <pre>On 03/06/2013 01:21 PM, Vineet Gupta wrote:
&gt; Hi Jiang,
&gt; 
&gt; On Tuesday 05 March 2013 08:24 PM, Jiang Liu wrote:
&gt;&gt; The original goal of this patchset is to fix the bug reported by
&gt;&gt; <a class="moz-txt-link-freetext" href="https://bugzilla.kernel.org/show_bug.cgi?id=53501">https://bugzilla.kernel.org/show_bug.cgi?id=53501</a>
&gt;&gt;
&gt;&gt; Now it has also been expanded to reduce common code used by memory
&gt;&gt; initializion. In total it has reduced about 550 lines of code.
&gt;&gt;
&gt;&gt; Patch 1:
&gt;&gt; 	Extract common help functions from free_init_mem() and
&gt;&gt; 	free_initrd_mem() on different architectures.
&gt;&gt; Patch 2-27:
&gt;&gt; 	Use help functions to simplify free_init_mem() and
&gt;&gt; 	free_initrd_mem() on different architectures. This has reduced
&gt;&gt; 	about 500 lines of code.
&gt;&gt; Patch 28:
&gt;&gt; 	Introduce common help function to free highmem pages when
&gt;&gt; 	initializing memory subsystem.
&gt;&gt; Patch 29-32:
&gt;&gt; 	Adjust totalhigh_pages, totalram_pages and zone-&gt;managed_pages
&gt;&gt; 	altogether when reserving/unreserving pages.
&gt;&gt; Patch 33:
&gt;&gt; 	Change /sys/.../node/nodex/meminfo to report available pages
&gt;&gt; 	within the node as "MemTotal".
&gt;&gt;
&gt;&gt; We have only tested these patchset on x86 platforms, and have done basic
&gt;&gt; compliation tests using cross-compilers from <a class="moz-txt-link-abbreviated" href="ftp://ftp.kernel.org">ftp.kernel.org</a>. That means
&gt;&gt; some code may not pass compilation on some architectures. So any help
&gt;&gt; to test this patchset are welcomed!
&gt;&gt;
&gt;&gt; Jiang Liu (33):
&gt;&gt;   mm: introduce common help functions to deal with reserved/managed
&gt;&gt;     pages
&gt;&gt;   mm/alpha: use common help functions to free reserved pages
&gt;&gt;   mm/ARM: use common help functions to free reserved pages
&gt;&gt;   mm/avr32: use common help functions to free reserved pages
&gt;&gt;   mm/blackfin: use common help functions to free reserved pages
&gt;&gt;   mm/c6x: use common help functions to free reserved pages
&gt;&gt;   mm/cris: use common help functions to free reserved pages
&gt;&gt;   mm/FRV: use common help functions to free reserved pages
&gt;&gt;   mm/h8300: use common help functions to free reserved pages
&gt;&gt;   mm/IA64: use common help functions to free reserved pages
&gt;&gt;   mm/m32r: use common help functions to free reserved pages
&gt;&gt;   mm/m68k: use common help functions to free reserved pages
&gt;&gt;   mm/microblaze: use common help functions to free reserved pages
&gt;&gt;   mm/MIPS: use common help functions to free reserved pages
&gt;&gt;   mm/mn10300: use common help functions to free reserved pages
&gt;&gt;   mm/openrisc: use common help functions to free reserved pages
&gt;&gt;   mm/parisc: use common help functions to free reserved pages
&gt;&gt;   mm/ppc: use common help functions to free reserved pages
&gt;&gt;   mm/s390: use common help functions to free reserved pages
&gt;&gt;   mm/score: use common help functions to free reserved pages
&gt;&gt;   mm/SH: use common help functions to free reserved pages
&gt;&gt;   mm/SPARC: use common help functions to free reserved pages
&gt;&gt;   mm/um: use common help functions to free reserved pages
&gt;&gt;   mm/unicore32: use common help functions to free reserved pages
&gt;&gt;   mm/x86: use common help functions to free reserved pages
&gt;&gt;   mm/xtensa: use common help functions to free reserved pages
&gt;&gt;   mm,kexec: use common help functions to free reserved pages
&gt;&gt;   mm: introduce free_highmem_page() helper to free highmem pages inti
&gt;&gt;     buddy system
&gt;&gt;   mm: accurately calculate zone-&gt;managed_pages for highmem zones
&gt;&gt;   mm: use a dedicated lock to protect totalram_pages and
&gt;&gt;     zone-&gt;managed_pages
&gt;&gt;   mm: avoid using __free_pages_bootmem() at runtime
&gt;&gt;   mm: correctly update zone-&gt;mamaged_pages
&gt;&gt;   mm: report available pages as "MemTotal" for each NUMA node
&gt; 
&gt; I'm not sure what baseline your patches are based off of - however as part of
&gt; 3.9-rc1, two new architectures were merged (arc and metag). It would be ideal if
&gt; they got updated them as part of this series itself - if possible. Please let me know.
&gt; 
&gt; Thx,
&gt; -Vineet

Hi Vineet,
	I have rebased the patchset to v3.9-rc1, but haven't noticed these two
new architectures. So how about the attached three patches?
	Regards!
	Gerry




</pre>
      <br>
      <br>
    </div>
    <br>
  </body>
</html>

--------------060000040705080005090009--

--------------040600030405000409030405
Content-Type: text/x-patch;
	name="0001-mm-arc-use-common-help-functions-to-free-reserved-pa.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-mm-arc-use-common-help-functions-to-free-reserved-pa.pa";
	filename*1="tch"

diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index caf797d..727d479 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -144,37 +144,18 @@ void __init mem_init(void)
 		PAGES_TO_KB(reserved_pages));
 }
 
-static void __init free_init_pages(const char *what, unsigned long begin,
-				   unsigned long end)
-{
-	unsigned long addr;
-
-	pr_info("Freeing %s: %ldk [%lx] to [%lx]\n",
-		what, TO_KB(end - begin), begin, end);
-
-	/* need to check that the page we free is not a partial page */
-	for (addr = begin; addr + PAGE_SIZE <= end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-}
-
 /*
  * free_initmem: Free all the __init memory.
  */
 void __init_refok free_initmem(void)
 {
-	free_init_pages("unused kernel memory",
-			(unsigned long)__init_begin,
-			(unsigned long)__init_end);
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_init_pages("initrd memory", start, end);
+	free_reserved_area(start, end, 0, "initrd");
 }
 #endif
 
-- 
1.7.9.5



--------------040600030405000409030405
Content-Type: text/x-patch;
	name="0002-mm-metag-use-common-help-functions-to-free-reserved-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0002-mm-metag-use-common-help-functions-to-free-reserved-.pa";
	filename*1="tch"

diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index 504a398..c6784fb 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -412,32 +412,15 @@ void __init mem_init(void)
 	return;
 }
 
-static void free_init_pages(char *what, unsigned long begin, unsigned long end)
-{
-	unsigned long addr;
-
-	for (addr = begin; addr < end; addr += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		free_page(addr);
-		totalram_pages++;
-	}
-	pr_info("Freeing %s: %luk freed\n", what, (end - begin) >> 10);
-}
-
 void free_initmem(void)
 {
-	free_init_pages("unused kernel memory",
-			(unsigned long)(&__init_begin),
-			(unsigned long)(&__init_end));
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	end = end & PAGE_MASK;
-	free_init_pages("initrd memory", start, end);
+	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
 }
 #endif
 
-- 
1.7.9.5



--------------040600030405000409030405
Content-Type: text/x-patch; name="0003-free-highmem-metag.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="0003-free-highmem-metag.patch"

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 40a5bc2..400a383 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -519,10 +519,8 @@ static void __init free_unused_memmap(struct meminfo *mi)
 #ifdef CONFIG_HIGHMEM
 static inline void free_area_high(unsigned long pfn, unsigned long end)
 {
-	for (; pfn < end; pfn++) {
-		__free_reserved_page(pfn_to_page(pfn));
-		totalhigh_pages++;
-	}
+	for (; pfn < end; pfn++)
+		free_highmem_page(pfn_to_page(pfn));
 }
 #endif
 
diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index c6784fb..7449af0 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -380,13 +380,8 @@ void __init mem_init(void)
 
 #ifdef CONFIG_HIGHMEM
 	unsigned long tmp;
-	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
-		struct page *page = pfn_to_page(tmp);
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
-	}
+	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++)
+		free_highmem_page(pfn_to_page(tmp));
 	totalram_pages += totalhigh_pages;
 	num_physpages += totalhigh_pages;
 #endif /* CONFIG_HIGHMEM */
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 9be5302..d0fe2a8 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -82,10 +82,7 @@ static unsigned long highmem_setup(void)
 		/* FIXME not sure about */
 		if (memblock_is_reserved(pfn << PAGE_SHIFT))
 			continue;
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
+		free_highmem_page(page);
 		reservedpages++;
 	}
 	totalram_pages += totalhigh_pages;
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 60f7c61..3105494 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -393,10 +393,7 @@ void __init mem_init(void)
 			SetPageReserved(page);
 			continue;
 		}
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
+		free_highmem_page(page);
 	}
 	totalram_pages += totalhigh_pages;
 	num_physpages += totalhigh_pages;
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index c756713..79eb16b 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -352,10 +352,7 @@ void __init mem_init(void)
 			struct page *page = pfn_to_page(pfn);
 			if (memblock_is_reserved(paddr))
 				continue;
-			ClearPageReserved(page);
-			init_page_count(page);
-			__free_page(page);
-			totalhigh_pages++;
+			free_higmem_page(page);
 			reservedpages--;
 		}
 		totalram_pages += totalhigh_pages;
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 2a7b6eb..cd4c78c 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -282,14 +282,8 @@ static void map_high_region(unsigned long start_pfn, unsigned long end_pfn)
 	printk("mapping high region %08lx - %08lx\n", start_pfn, end_pfn);
 #endif
 
-	for (tmp = start_pfn; tmp < end_pfn; tmp++) {
-		struct page *page = pfn_to_page(tmp);
-
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
-	}
+	for (tmp = start_pfn; tmp < end_pfn; tmp++)
+		free_higmem_page(pfn_to_page(tmp));
 }
 
 void __init mem_init(void)
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index d5ac802..fea5c9d 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -42,17 +42,12 @@ static unsigned long brk_end;
 static void setup_highmem(unsigned long highmem_start,
 			  unsigned long highmem_len)
 {
-	struct page *page;
 	unsigned long highmem_pfn;
 	int i;
 
 	highmem_pfn = __pa(highmem_start) >> PAGE_SHIFT;
-	for (i = 0; i < highmem_len >> PAGE_SHIFT; i++) {
-		page = &mem_map[highmem_pfn + i];
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-	}
+	for (i = 0; i < highmem_len >> PAGE_SHIFT; i++)
+		free_highmem_page(&mem_map[highmem_pfn + i]);
 }
 #endif
 
@@ -73,7 +68,7 @@ void __init mem_init(void)
 	totalram_pages = free_all_bootmem();
 	max_low_pfn = totalram_pages;
 #ifdef CONFIG_HIGHMEM
-	totalhigh_pages = highmem >> PAGE_SHIFT;
+	setup_highmem(end_iomem, highmem);
 	totalram_pages += totalhigh_pages;
 #endif
 	num_physpages = totalram_pages;
@@ -81,10 +76,6 @@ void __init mem_init(void)
 	printk(KERN_INFO "Memory: %luk available\n",
 	       nr_free_pages() << (PAGE_SHIFT-10));
 	kmalloc_ok = 1;
-
-#ifdef CONFIG_HIGHMEM
-	setup_highmem(end_iomem, highmem);
-#endif
 }
 
 /*
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 2d19001..3ac7e31 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -427,14 +427,6 @@ static void __init permanent_kmaps_init(pgd_t *pgd_base)
 	pkmap_page_table = pte;
 }
 
-static void __init add_one_highpage_init(struct page *page)
-{
-	ClearPageReserved(page);
-	init_page_count(page);
-	__free_page(page);
-	totalhigh_pages++;
-}
-
 void __init add_highpages_with_active_regions(int nid,
 			 unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -448,7 +440,7 @@ void __init add_highpages_with_active_regions(int nid,
 					      start_pfn, end_pfn);
 		for ( ; pfn < e_pfn; pfn++)
 			if (pfn_valid(pfn))
-				add_one_highpage_init(pfn_to_page(pfn));
+				free_highmem_page(pfn_to_page(pfn));
 	}
 }
 #else
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 881461c..4d1509b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1296,6 +1296,9 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 extern void free_initmem(void);
 
 /* Help functions to deal with reserved/managed pages. */
+#ifdef	CONFIG_HIGHMEM
+extern void free_highmem_page(struct page *page);
+#endif
 extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
 					int poison, char *s);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fadb09..ad2f619 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5133,6 +5133,14 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
 	return pages;
 }
 
+#ifdef	CONFIG_HIGHMEM
+void free_highmem_page(struct page *page)
+{
+	__free_reserved_page(page);
+	totalhigh_pages++;
+}
+#endif
+
 /**
  * set_dma_reserve - set the specified number of pages reserved in the first zone
  * @new_dma_reserve: The number of pages to mark reserved


--------------040600030405000409030405--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
