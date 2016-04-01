Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A82206B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 23:15:25 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id e128so62686117pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 20:15:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id yk5si520053pab.160.2016.03.31.20.15.24
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 20:15:24 -0700 (PDT)
Date: Fri, 1 Apr 2016 11:13:43 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 4/4] mtd: provide helper to prepare buffers for DMA
 operations
Message-ID: <201604011151.adkPJgri%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
In-Reply-To: <1459427384-21374-5-git-send-email-boris.brezillon@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: kbuild-all@01.org, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>, Mark Brown <broonie@kernel.org>, linux-spi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, dmaengine@vger.kernel.org, Mauro Carvalho Chehab <m.chehab@samsung.com>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org, Richard Weinberger <richard@nod.at>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, Vignesh R <vigneshr@ti.com>, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Boris,

[auto build test ERROR on spi/for-next]
[also build test ERROR on v4.6-rc1 next-20160331]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Boris-Brezillon/scatterlist-sg_table-from-virtual-pointer/20160331-203118
base:   https://git.kernel.org/pub/scm/linux/kernel/git/broonie/spi for-next
config: m32r-m32104ut_defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m32r 

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/mtd/super.h:17:0,
                    from fs/romfs/storage.c:13:
>> include/linux/mtd/mtd.h:426:10: error: expected ';', ',' or ')' before 'enum'
             enum dma_data_direction dir)
             ^
   include/linux/mtd/mtd.h: In function 'mtd_unmap_buf':
>> include/linux/mtd/mtd.h:434:2: warning: 'return' with a value, in function returning void
     return -ENOTSUPP;
     ^
   fs/romfs/storage.c: At top level:
   include/linux/mtd/mtd.h:431:13: warning: 'mtd_unmap_buf' defined but not used [-Wunused-function]
    static void mtd_unmap_buf(struct mtd_info *mtd, struct device *dev,
                ^
--
   In file included from include/linux/mtd/super.h:17:0,
                    from fs/romfs/super.c:72:
>> include/linux/mtd/mtd.h:426:10: error: expected ';', ',' or ')' before 'enum'
             enum dma_data_direction dir)
             ^
   include/linux/mtd/mtd.h: In function 'mtd_unmap_buf':
>> include/linux/mtd/mtd.h:434:2: warning: 'return' with a value, in function returning void
     return -ENOTSUPP;
     ^
   fs/romfs/super.c: At top level:
   include/linux/mtd/mtd.h:431:13: warning: 'mtd_unmap_buf' defined but not used [-Wunused-function]
    static void mtd_unmap_buf(struct mtd_info *mtd, struct device *dev,
                ^

vim +426 include/linux/mtd/mtd.h

   420			   struct sg_table *sgt, enum dma_data_direction dir);
   421	#else
   422	static inline int mtd_map_buf(struct mtd_info *mtd, struct device *dev,
   423				      struct sg_table *sgt, const void *buf,
   424				      size_t len,
   425				      const struct sg_constraints *constraints
 > 426				      enum dma_data_direction dir)
   427	{
   428		return -ENOTSUPP;
   429	}
   430	
   431	static void mtd_unmap_buf(struct mtd_info *mtd, struct device *dev,
   432				  struct sg_table *sgt, enum dma_data_direction dir)
   433	{
 > 434		return -ENOTSUPP;
   435	}
   436	#endif
   437	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--bg08WKrSYDhXBjb5
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--bg08WKrSYDhXBjb5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
