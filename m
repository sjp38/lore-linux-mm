Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 963576B2420
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:33:16 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bg5-v6so874495plb.20
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 04:33:16 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id bh1-v6si1396746plb.190.2018.08.22.04.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 04:33:14 -0700 (PDT)
Date: Wed, 22 Aug 2018 19:32:05 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 187/242] mm/memblock.c:1290:6: error:
 'early_region_idx' undeclared; did you mean 'nommu_region_sem'?
Message-ID: <201808221902.zZGLYOTY%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <jia.he@hxt-semitech.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   10b78d76f1897885d7753586ecd113e9d6728c5d
commit: be2e6e87ac5e7f8f30c442bb1a042266e1ab6fcd [187/242] mm/memblock: introduce pfn_valid_region()
config: arm-allnoconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout be2e6e87ac5e7f8f30c442bb1a042266e1ab6fcd
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=arm 

All errors (new ones prefixed by >>):

   mm/memblock.c: In function 'pfn_valid_region':
>> mm/memblock.c:1290:6: error: 'early_region_idx' undeclared (first use in this function); did you mean 'nommu_region_sem'?
     if (early_region_idx != -1) {
         ^~~~~~~~~~~~~~~~
         nommu_region_sem
   mm/memblock.c:1290:6: note: each undeclared identifier is reported only once for each function it appears in
   mm/memblock.c:1305:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^

vim +1290 mm/memblock.c

  1283	
  1284	int pfn_valid_region(ulong pfn)
  1285	{
  1286		ulong start_pfn, end_pfn;
  1287		struct memblock_type *type = &memblock.memory;
  1288		struct memblock_region *regions = type->regions;
  1289	
> 1290		if (early_region_idx != -1) {
  1291			start_pfn = PFN_DOWN(regions[early_region_idx].base);
  1292			end_pfn = PFN_DOWN(regions[early_region_idx].base +
  1293						regions[early_region_idx].size);
  1294	
  1295			if (pfn >= start_pfn && pfn < end_pfn)
  1296				return !memblock_is_nomap(
  1297						&regions[early_region_idx]);
  1298		}
  1299	
  1300		early_region_idx = memblock_search_pfn_regions(pfn);
  1301		if (early_region_idx == -1)
  1302			return false;
  1303	
  1304		return !memblock_is_nomap(&regions[early_region_idx]);
  1305	}
  1306	EXPORT_SYMBOL(pfn_valid_region);
  1307	#endif /*CONFIG_HAVE_MEMBLOCK_PFN_VALID*/
  1308	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--2fHTh5uZTiUOsy+g
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--2fHTh5uZTiUOsy+g--
