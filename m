Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 446A26B0399
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:28:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so60511727pfb.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 04:28:21 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1si10194138plm.58.2017.02.17.04.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 04:28:20 -0800 (PST)
Date: Fri, 17 Feb 2017 20:27:43 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 3/6] mm/migrate: Add copy_pages_mthread function
Message-ID: <201702172013.pEgvczPM%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Content-Disposition: inline
In-Reply-To: <20170217112453.307-4-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Zi,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.10-rc8 next-20170216]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/Enable-parallel-page-migration/20170217-200523
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   mm/copy_pages_mthread.c: In function 'copy_pages_mthread':
>> mm/copy_pages_mthread.c:49:10: warning: assignment discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
     cpumask = cpumask_of_node(node);
             ^

vim +/const +49 mm/copy_pages_mthread.c

    33	static void copythread(struct work_struct *work)
    34	{
    35		struct copy_info *info = (struct copy_info *) work;
    36	
    37		copy_pages(info->to, info->from, info->chunk_size);
    38	}
    39	
    40	int copy_pages_mthread(struct page *to, struct page *from, int nr_pages)
    41	{
    42		struct cpumask *cpumask;
    43		struct copy_info *work_items;
    44		char *vto, *vfrom;
    45		unsigned long i, cthreads, cpu, node, chunk_size;
    46		int cpu_id_list[32] = {0};
    47	
    48		node = page_to_nid(to);
  > 49		cpumask = cpumask_of_node(node);
    50		cthreads = nr_copythreads;
    51		cthreads = min_t(unsigned int, cthreads, cpumask_weight(cpumask));
    52		cthreads = (cthreads / 2) * 2;
    53		work_items = kcalloc(cthreads, sizeof(struct copy_info), GFP_KERNEL);
    54		if (!work_items)
    55			return -ENOMEM;
    56	
    57		i = 0;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--XsQoSWH+UP9D9v3l
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
fWrAU+3COsHdcDUJtCAB+AW3HfqSu1oAAA==

--XsQoSWH+UP9D9v3l--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
