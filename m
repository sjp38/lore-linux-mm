Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2B936B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 23:42:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k4so6437280pgq.15
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 20:42:21 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m22si9924635pgv.789.2018.01.09.20.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 20:42:20 -0800 (PST)
Date: Wed, 10 Jan 2018 12:42:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [aaron:for_lkp_skl_2sp2_test 151/225]
 drivers/net//ethernet/netronome/nfp/nfp_net_common.c:1188:116: error:
 '__GFP_COLD' undeclared
Message-ID: <20180110044218.gq5nxa4cuvqpamlg@wfg-t540p.sh.intel.com>
References: <201801100639.1FfQRG2U%fengguang.wu@intel.com>
 <1515548125.31639.2.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1515548125.31639.2.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Lu, Aaron" <aaron.lu@intel.com>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

>I just removed the branch, there should be no more such reports.

The other option is to add "rfc" or "RFC" somewhere in the branch
name. I'll mark such branches as private reporting ones.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
