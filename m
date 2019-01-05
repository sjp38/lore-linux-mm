Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD1C8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 14:44:54 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d18so39842191pfe.0
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 11:44:54 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p18si55475251plo.223.2019.01.05.11.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 11:44:53 -0800 (PST)
Date: Sun, 6 Jan 2019 03:44:14 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <201901060319.mJwMkpiz%fengguang.wu@intel.com>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: kbuild-all@01.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jiri,

I love your patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.20 next-20190103]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Jiri-Kosina/mm-mincore-allow-for-making-sys_mincore-privileged/20190106-013707
config: c6x-evmc6678_defconfig (attached as .config)
compiler: c6x-elf-gcc (GCC) 8.1.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=8.1.0 make.cross ARCH=c6x 

All errors (new ones prefixed by >>):

>> kernel/sysctl.o:(.fardata+0x6a0): undefined reference to `sysctl_mincore_privileged'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--lrZ03NoBR/3+SXJZ
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
hNr5ttVeqR/x+v8DQRMqIG5GAAA=

--lrZ03NoBR/3+SXJZ--
