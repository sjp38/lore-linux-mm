Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 9CF766B0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 13:28:11 -0500 (EST)
Date: Mon, 28 Jan 2013 19:28:09 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v3] mm: clean up soft_offline_page() (Re: [PATCH v2] mm: clean up soft_offline_page())
Message-ID: <20130128182809.GU30577@one.firstfloor.org>
References: <20130127014811.GL30577@one.firstfloor.org> <1359397090-9644-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359397090-9644-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gong.chen@linux.intel.com

> 
> As Xishi pointed out, the patch was broken. Mce-test did catch it, but the
> related testcase HWPOISON-SOFT showed PASS falsely, so I overlooked it.

Oops. Please send a patch to Gong to fix that in mce-test

> Now I confirm that tsoft.c and tsoftinj.c in mce-test surely passes (returns
> with success exitcode) with the fixed one (attached).

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
