Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 589616B04C8
	for <linux-mm@kvack.org>; Sat, 19 Aug 2017 16:31:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g13so19793944pfm.15
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 13:31:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i4si111842pfb.107.2017.08.19.13.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Aug 2017 13:31:05 -0700 (PDT)
Date: Sun, 20 Aug 2017 04:30:57 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v14 1/5] lib/xbitmap: Introduce xbitmap
Message-ID: <201708200432.9S5MMEiT%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
In-Reply-To: <1502940416-42944-2-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: kbuild-all@01.org, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Matthew,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.13-rc5 next-20170817]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Wei-Wang/lib-xbitmap-Introduce-xbitmap/20170820-035516
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   lib/xbitmap.c: In function 'xb_test_bit':
>> lib/xbitmap.c:153:26: warning: passing argument 1 of 'xb_bit_ops' discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
     return (bool)xb_bit_ops(xb, bit, XB_TEST);
                             ^~
   lib/xbitmap.c:23:12: note: expected 'struct xb *' but argument is of type 'const struct xb *'
    static int xb_bit_ops(struct xb *xb, unsigned long bit, enum xb_ops ops)
               ^~~~~~~~~~

vim +153 lib/xbitmap.c

   142	
   143	/**
   144	 * xb_test_bit - test a bit in the xbitmap
   145	 * @xb: the xbitmap tree used to record the bit
   146	 * @bit: index of the bit to set
   147	 *
   148	 * This function is used to test a bit in the xbitmap.
   149	 * Returns: 1 if the bit is set, or 0 otherwise.
   150	 */
   151	bool xb_test_bit(const struct xb *xb, unsigned long bit)
   152	{
 > 153		return (bool)xb_bit_ops(xb, bit, XB_TEST);
   154	}
   155	EXPORT_SYMBOL(xb_test_bit);
   156	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--k1lZvvs/B4yU6o8G
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
uTbYa5BZJ1gynlUDq+c/zchrQlpfAAA=

--k1lZvvs/B4yU6o8G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
