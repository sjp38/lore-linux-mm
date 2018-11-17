Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1666A6B0CB5
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 21:26:32 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so11740896pfj.15
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 18:26:32 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 11-v6si34521331pfx.102.2018.11.16.18.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 18:26:29 -0800 (PST)
Date: Sat, 17 Nov 2018 10:26:25 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 47/137] htmldocs: mm/memblock.c:1261: warning:
 Function parameter or member 'out_spfn' not described in
 '__next_mem_pfn_range_in_zone'
Message-ID: <201811171022.9O8KA7ol%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   4de8d18fa38298433f161f8780b5e1b0f01a8c17
commit: 711bb3ee3832a764cb2ea03e97b7183b938e1f6c [47/137] mm: implement new zone specific memblock iterator
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   WARNING: convert(1) not found, for SVG to PDF conversion install ImageMagick (https://www.imagemagick.org)
   mm/memblock.c:1261: warning: Excess function parameter 'out_start' description in '__next_mem_pfn_range_in_zone'
   mm/memblock.c:1261: warning: Excess function parameter 'out_end' description in '__next_mem_pfn_range_in_zone'
>> mm/memblock.c:1261: warning: Function parameter or member 'out_spfn' not described in '__next_mem_pfn_range_in_zone'
>> mm/memblock.c:1261: warning: Function parameter or member 'out_epfn' not described in '__next_mem_pfn_range_in_zone'
   mm/memblock.c:1261: warning: Excess function parameter 'out_start' description in '__next_mem_pfn_range_in_zone'
   mm/memblock.c:1261: warning: Excess function parameter 'out_end' description in '__next_mem_pfn_range_in_zone'
   include/linux/rcutree.h:1: warning: no structured comments found
   kernel/rcu/tree.c:684: warning: Excess function parameter 'irq' description in 'rcu_nmi_exit'
   include/linux/srcu.h:175: warning: Function parameter or member 'p' not described in 'srcu_dereference_notrace'
   include/linux/srcu.h:175: warning: Function parameter or member 'sp' not described in 'srcu_dereference_notrace'
   include/linux/gfp.h:1: warning: no structured comments found
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.ibss' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.connect' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.keys' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.ie' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.ie_len' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.bssid' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.ssid' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.default_key' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.default_mgmt_key' not described in 'wireless_dev'
   include/net/cfg80211.h:4439: warning: Function parameter or member 'wext.prev_bssid_valid' not described in 'wireless_dev'
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '

vim +1261 mm/memblock.c

  1211	
  1212	/**
  1213	 * memblock_set_node - set node ID on memblock regions
  1214	 * @base: base of area to set node ID for
  1215	 * @size: size of area to set node ID for
  1216	 * @type: memblock type to set node ID for
  1217	 * @nid: node ID to set
  1218	 *
  1219	 * Set the nid of memblock @type regions in [@base, @base + @size) to @nid.
  1220	 * Regions which cross the area boundaries are split as necessary.
  1221	 *
  1222	 * Return:
  1223	 * 0 on success, -errno on failure.
  1224	 */
  1225	int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
  1226					      struct memblock_type *type, int nid)
  1227	{
  1228		int start_rgn, end_rgn;
  1229		int i, ret;
  1230	
  1231		ret = memblock_isolate_range(type, base, size, &start_rgn, &end_rgn);
  1232		if (ret)
  1233			return ret;
  1234	
  1235		for (i = start_rgn; i < end_rgn; i++)
  1236			memblock_set_region_node(&type->regions[i], nid);
  1237	
  1238		memblock_merge_regions(type);
  1239		return 0;
  1240	}
  1241	#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
  1242	#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
  1243	/**
  1244	 * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
  1245	 *
  1246	 * @idx: pointer to u64 loop variable
  1247	 * @zone: zone in which all of the memory blocks reside
  1248	 * @out_start: ptr to ulong for start pfn of the range, can be %NULL
  1249	 * @out_end: ptr to ulong for end pfn of the range, can be %NULL
  1250	 *
  1251	 * This function is meant to be a zone/pfn specific wrapper for the
  1252	 * for_each_mem_range type iterators. Specifically they are used in the
  1253	 * deferred memory init routines and as such we were duplicating much of
  1254	 * this logic throughout the code. So instead of having it in multiple
  1255	 * locations it seemed like it would make more sense to centralize this to
  1256	 * one new iterator that does everything they need.
  1257	 */
  1258	void __init_memblock
  1259	__next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
  1260				     unsigned long *out_spfn, unsigned long *out_epfn)
> 1261	{
  1262		int zone_nid = zone_to_nid(zone);
  1263		phys_addr_t spa, epa;
  1264		int nid;
  1265	
  1266		__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
  1267				 &memblock.memory, &memblock.reserved,
  1268				 &spa, &epa, &nid);
  1269	
  1270		while (*idx != ULLONG_MAX) {
  1271			unsigned long epfn = PFN_DOWN(epa);
  1272			unsigned long spfn = PFN_UP(spa);
  1273	
  1274			/*
  1275			 * Verify the end is at least past the start of the zone and
  1276			 * that we have at least one PFN to initialize.
  1277			 */
  1278			if (zone->zone_start_pfn < epfn && spfn < epfn) {
  1279				/* if we went too far just stop searching */
  1280				if (zone_end_pfn(zone) <= spfn)
  1281					break;
  1282	
  1283				if (out_spfn)
  1284					*out_spfn = max(zone->zone_start_pfn, spfn);
  1285				if (out_epfn)
  1286					*out_epfn = min(zone_end_pfn(zone), epfn);
  1287	
  1288				return;
  1289			}
  1290	
  1291			__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
  1292					 &memblock.memory, &memblock.reserved,
  1293					 &spa, &epa, &nid);
  1294		}
  1295	
  1296		/* signal end of iteration */
  1297		*idx = ULLONG_MAX;
  1298		if (out_spfn)
  1299			*out_spfn = ULONG_MAX;
  1300		if (out_epfn)
  1301			*out_epfn = 0;
  1302	}
  1303	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--sdtB3X0nJg68CQEu
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
h7w19x8Rv/WzrFsAAA==

--sdtB3X0nJg68CQEu--
