Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88BBA6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 23:28:48 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w186so5097443pgb.10
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 20:28:48 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b36si1555762pli.622.2018.01.09.20.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 20:28:47 -0800 (PST)
Date: Wed, 10 Jan 2018 12:29:23 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [aaron:for_lkp_skl_2sp2_test 151/225]
 drivers/net//ethernet/netronome/nfp/nfp_net_common.c:1188:116: error:
 '__GFP_COLD' undeclared
Message-ID: <20180110042923.GA515@intel.com>
References: <201801100639.1FfQRG2U%fengguang.wu@intel.com>
 <1515548125.31639.2.camel@intel.com>
 <20180110042148.x3nfjnkttdu3irib@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110042148.x3nfjnkttdu3irib@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Jan 10, 2018 at 12:21:48PM +0800, Fengguang Wu wrote:
> On Wed, Jan 10, 2018 at 09:34:47AM +0800, Aaron Lu wrote:
> > Please ignore this build report.
> > 
> > I thought the robot has done its job but looks like it is still
> > building that branch.
> 
> Sorry about that! Although most reports will be caught in the 24 hour,
> the 0-day build bot will nowadays typically continue tests for weeks
> to improve coverage.

Thanks for the explanation.

I have deleted that branch on my tree, I assume that could stop the bot
from building it anymore.

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
