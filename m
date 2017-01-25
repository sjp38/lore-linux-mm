Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 127B96B025E
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:00:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e4so130505871pfg.4
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 18:00:11 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f88si21673961pfk.36.2017.01.24.18.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 18:00:10 -0800 (PST)
Date: Wed, 25 Jan 2017 09:59:54 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 02/12] mm: introduce page_check_walk()
Message-ID: <201701250909.CwXslKN1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Content-Disposition: inline
In-Reply-To: <20170124162824.91275-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: kbuild-all@01.org, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Kirill,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.10-rc5 next-20170124]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Kirill-A-Shutemov/Fix-few-rmap-related-THP-bugs/20170125-081918
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: sparc64-allnoconfig (attached as .config)
compiler: sparc64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sparc64 

All error/warnings (new ones prefixed by >>):

   mm/page_check.c: In function 'check_pte':
>> mm/page_check.c:48:38: error: invalid operands to binary - (have 'void *' and 'struct page *')
      if (migration_entry_to_page(entry) - pcw->page >=
                                         ^ ~~~~~~~~~
>> mm/page_check.c:52:38: warning: comparison of distinct pointer types lacks a cast
      if (migration_entry_to_page(entry) < pcw->page)
                                         ^

vim +48 mm/page_check.c

    42			swp_entry_t entry;
    43			if (!is_swap_pte(*pcw->pte))
    44				return false;
    45			entry = pte_to_swp_entry(*pcw->pte);
    46			if (!is_migration_entry(entry))
    47				return false;
  > 48			if (migration_entry_to_page(entry) - pcw->page >=
    49					hpage_nr_pages(pcw->page)) {
    50				return false;
    51			}
  > 52			if (migration_entry_to_page(entry) < pcw->page)
    53				return false;
    54		} else {
    55			if (!pte_present(*pcw->pte))

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--3V7upXqbjpZ4EhLz
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AAA=

--3V7upXqbjpZ4EhLz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
