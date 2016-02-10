Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C5DD96B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 06:08:00 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id cy9so10517873pac.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 03:08:00 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id l84si4458791pfb.158.2016.02.10.03.08.00
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 03:08:00 -0800 (PST)
Date: Wed, 10 Feb 2016 19:06:28 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 4330/4460] DockBook: drivers/rapidio/rio.c:568:
 warning: No description found for parameter 'mport'
Message-ID: <201602101926.kxEbVffs%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Bounine <alexandre.bounine@idt.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   b613c2bfa3e843fdeff95878edc7326b763abd1b
commit: 6d643d52a9d10ccf67d6990ff28c9042ab68f473 [4330/4460] rapidio: move rio_pw_enable into core code
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

>> drivers/rapidio/rio.c:568: warning: No description found for parameter 'mport'
>> drivers/rapidio/rio.c:568: warning: Excess function parameter 'port' description in 'rio_pw_enable'
   include/linux/rio.h:301: warning: No description found for parameter 'lock'
   include/linux/rio.h:301: warning: Excess struct/union/enum/typedef member 'mutex' description in 'rio_mport'
   include/linux/rio.h:334: warning: No description found for parameter 'dev'
>> drivers/rapidio/rio.c:568: warning: No description found for parameter 'mport'
>> drivers/rapidio/rio.c:568: warning: Excess function parameter 'port' description in 'rio_pw_enable'

vim +/mport +568 drivers/rapidio/rio.c

   552		if (rdev->pwcback) {
   553			rdev->pwcback = NULL;
   554			rc = 0;
   555		}
   556	
   557		spin_unlock(&rio_global_list_lock);
   558		return rc;
   559	}
   560	EXPORT_SYMBOL_GPL(rio_release_inb_pwrite);
   561	
   562	/**
   563	 * rio_pw_enable - Enables/disables port-write handling by a master port
   564	 * @port: Master port associated with port-write handling
   565	 * @enable:  1=enable,  0=disable
   566	 */
   567	void rio_pw_enable(struct rio_mport *mport, int enable)
 > 568	{
   569		if (mport->ops->pwenable) {
   570			mutex_lock(&mport->lock);
   571	
   572			if ((enable && ++mport->pwe_refcnt == 1) ||
   573			    (!enable && mport->pwe_refcnt && --mport->pwe_refcnt == 0))
   574				mport->ops->pwenable(mport, enable);
   575			mutex_unlock(&mport->lock);
   576		}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--AqsLC8rIMeq19msA
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
MxqA/8vd9prxWAAA

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
