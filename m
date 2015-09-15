Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 869036B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 12:52:52 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so37674823wic.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:52:52 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id o7si21340212wjq.49.2015.09.15.09.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 09:52:51 -0700 (PDT)
Date: Tue, 15 Sep 2015 18:52:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/1] fs: global sync to not clear error status of
 individual inodes
Message-ID: <20150915165250.GC1747@two.firstfloor.org>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915152006.GD2905@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915152006.GD2905@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Junichi Nomura <j-nomura@ce.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "david@fromorbit.com" <david@fromorbit.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> Is this an actual problem?  Write errors usually indicate that the

There are transaction systems that need to track errors at the level
of the individual IO.  So yes we should guarantee that if a particular
sync failed an error is always returned.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
