Date: Tue, 5 Dec 2006 21:45:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] vmemmap on sparsemem v2
Message-Id: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andy <apw@shadowen.org>, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi, this is patches for the virtual mem_map on sparsemem.

The virtual mem_map will reduce costs of page_to_pfn/pfn_to_page of
SPARSEMEM_EXTREME.

I post this series in October but haven't been able to update.
I rewrote the whole patches and reflected comments from Christoph-san and Andy-san.
tested on ia64/tiger4.

Changes v1 -> v2:
- support memory hotplug case.
- uses static address for vmem_map (ia64)
- added optimized pfn_valid() for ia64  (experimental)

consists of 5 patches:
1.. generic vmemmap_sparsemem
2.. memory hotplug support
3.. ia64 vmemmap_sparsemem definitions
4.. optimized pfn_valid  (experimental) 
5.. changes for pfn_valid  (experimental)

I don't manage large-page-size vmem_map in this series to keep patches simple.
maybe I need more study to implement it in clean way.

This patch is against 2.6.19-rc6-mm2, and I'll rebase this to the next -mm
(possibly). So this patch is just for RFC.

Any comments are welcome.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
