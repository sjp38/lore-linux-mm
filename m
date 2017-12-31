Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 735FC6B0038
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 07:38:07 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so27553617plh.18
        for <linux-mm@kvack.org>; Sun, 31 Dec 2017 04:38:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w11si27678090pgq.163.2017.12.31.04.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Dec 2017 04:38:06 -0800 (PST)
Date: Sun, 31 Dec 2017 20:37:10 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2] ksm: replace jhash2 with faster hash
Message-ID: <201712312046.UvzAFo2X%fengguang.wu@intel.com>
References: <20171229095241.23345-1-nefelim4ag@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171229095241.23345-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>

Hi Timofey,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on mmotm/master]
[also build test WARNING on v4.15-rc5 next-20171222]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Timofey-Titovets/ksm-replace-jhash2-with-faster-hash/20171231-155425
base:   git://git.cmpxchg.org/linux-mmotm.git master
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
