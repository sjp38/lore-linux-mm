Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id F04826B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 13:33:15 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3] mm: clean up soft_offline_page() (Re: [PATCH v2] mm: clean up soft_offline_page())
Date: Mon, 28 Jan 2013 13:32:56 -0500
Message-Id: <1359397976-10205-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130128182809.GU30577@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gong.chen@linux.intel.com

On Mon, Jan 28, 2013 at 07:28:09PM +0100, Andi Kleen wrote:
> > 
> > As Xishi pointed out, the patch was broken. Mce-test did catch it, but the
> > related testcase HWPOISON-SOFT showed PASS falsely, so I overlooked it.
> 
> Oops. Please send a patch to Gong to fix that in mce-test

OK. I'll try this soon.

Thanks,
Naoya

> > Now I confirm that tsoft.c and tsoftinj.c in mce-test surely passes (returns
> > with success exitcode) with the fixed one (attached).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
