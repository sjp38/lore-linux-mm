Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D29AD8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 03:20:48 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a9so11373105pla.2
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 00:20:48 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z5si11007476plh.133.2018.12.18.00.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 00:20:47 -0800 (PST)
Date: Tue, 18 Dec 2018 16:20:22 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v6 3/6] acpi/numa: Set the memory-side-cache size in
 memblocks
Message-ID: <201812181659.x2nZyCXb%fengguang.wu@intel.com>
References: <154510701860.1941238.2239802602407206153.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Content-Disposition: inline
In-Reply-To: <154510701860.1941238.2239802602407206153.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mike Rapoport <rppt@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Keith,

I love your patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.20-rc7 next-20181217]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Dan-Williams/mm-Randomize-free-memory/20181218-130230
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   WARNING: convert(1) not found, for SVG to PDF conversion install ImageMagick (https://www.imagemagick.org)
   mm/memblock.c:840: warning: Excess function parameter 'direct' description in 'memblock_set_sidecache'
>> mm/memblock.c:840: warning: Function parameter or member 'direct_mapped' not described in 'memblock_set_sidecache'
   mm/memblock.c:840: warning: Excess function parameter 'direct' description in 'memblock_set_sidecache'
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
   include/net/cfg80211.h:2838: warning: cannot understand function prototype: 'struct cfg80211_ftm_responder_stats '

vim +840 mm/memblock.c

   824	
   825	#ifdef CONFIG_HAVE_MEMBLOCK_CACHE_INFO
   826	/**
   827	 * memblock_set_sidecache - set the system memory cache info
   828	 * @base: base address of the region
   829	 * @size: size of the region
   830	 * @cache_size: system side cache size in bytes
   831	 * @direct: true if the cache has direct mapped associativity
   832	 *
   833	 * This function isolates region [@base, @base + @size), and saves the cache
   834	 * information.
   835	 *
   836	 * Return: 0 on success, -errno on failure.
   837	 */
   838	int __init_memblock memblock_set_sidecache(phys_addr_t base, phys_addr_t size,
   839				   phys_addr_t cache_size, bool direct_mapped)
 > 840	{
   841		struct memblock_type *type = &memblock.memory;
   842		int i, ret, start_rgn, end_rgn;
   843	
   844		ret = memblock_isolate_range(type, base, size, &start_rgn, &end_rgn);
   845		if (ret)
   846			return ret;
   847	
   848		for (i = start_rgn; i < end_rgn; i++) {
   849			struct memblock_region *r = &type->regions[i];
   850	
   851			r->cache_size = cache_size;
   852			r->direct_mapped = direct_mapped;
   853		}
   854	
   855		return 0;
   856	}
   857	#endif
   858	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--TB36FDmn/VVEgNH/
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
/gOpagT1qFsAAA==

--TB36FDmn/VVEgNH/--
