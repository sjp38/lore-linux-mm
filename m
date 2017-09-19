Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9A76B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 07:02:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so5947561pgn.2
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 04:02:40 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l11si1168482pgc.760.2017.09.19.04.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 04:02:39 -0700 (PDT)
Date: Tue, 19 Sep 2017 19:02:06 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/3] sched/loadavg: consolidate LOAD_INT, LOAD_FRAC macros
Message-ID: <201709191802.SLprAJBN%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
In-Reply-To: <20170918163434.GA11236@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kbuild-all@01.org, Taras Kondratiuk <takondra@cisco.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Johannes,

[auto build test ERROR on v4.13]
[cannot apply to mmotm/master linus/master tip/sched/core v4.14-rc1 next-20170919]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Johannes-Weiner/sched-loadavg-consolidate-LOAD_INT-LOAD_FRAC-macros/20170919-161057
config: c6x-evmc6678_defconfig (attached as .config)
compiler: c6x-elf-gcc (GCC) 6.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=c6x 

All errors (new ones prefixed by >>):

   mm/memdelay.o: In function `memdelay_task_change':
>> memdelay.c:(.text+0x2bc): undefined reference to `__c6xabi_divull'
   memdelay.c:(.text+0x438): undefined reference to `__c6xabi_divull'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--C7zPtVaVf+AK4Oqc
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--C7zPtVaVf+AK4Oqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
