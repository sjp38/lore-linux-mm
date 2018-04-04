Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6A196B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:03:55 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g61-v6so14785416plb.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:03:55 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f12si3749231pgq.411.2018.04.04.08.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:03:51 -0700 (PDT)
Date: Wed, 4 Apr 2018 23:03:39 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 6/9] trace_uprobe: Support SDT markers having
 reference count (semaphore)
Message-ID: <201804042247.DQrDzGk7%fengguang.wu@intel.com>
References: <20180404083110.18647-7-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404083110.18647-7-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com

Hi Ravi,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on tip/perf/core]
[also build test WARNING on v4.16 next-20180404]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Ravi-Bangoria/trace_uprobe-Support-SDT-markers-having-reference-count-semaphore/20180404-201900
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   kernel/trace/trace.h:1298:38: sparse: incorrect type in argument 1 (different address spaces) @@    expected struct event_filter *filter @@    got struct event_filtstruct event_filter *filter @@
   kernel/trace/trace.h:1298:38:    expected struct event_filter *filter
   kernel/trace/trace.h:1298:38:    got struct event_filter [noderef] <asn:4>*filter
>> kernel/trace/trace_uprobe.c:1001:6: sparse: symbol 'trace_uprobe_mmap' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
