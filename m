Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 77C2C6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 18:10:29 -0400 (EDT)
Date: Mon, 16 Sep 2013 18:09:57 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1379369397-ld8lbcn-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31CFD2D6@ORSMSX106.amr.corp.intel.com>
References: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130915001352.GQ18242@two.firstfloor.org>
 <3908561D78D1C84285E8C5FCA982C28F31CFD2D6@ORSMSX106.amr.corp.intel.com>
Subject: Re: [RESEND PATCH v2 1/4] mm/hwpoison: fix traverse hugetlbfs page to
 avoid printk flood
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Sep 16, 2013 at 09:50:06PM +0000, Luck, Tony wrote:
> This is good - but the real solution is to stop poisoning entire huge pages ... they should
> be broken into 4K pages and just one 4K page should be poisoned.
> 
> Naoya Horiguchi: I thought that you were looking at this problem some months ago. Any progress?

Sorry, I have no meaningful progress on this. Splitting hugepages is not
a trivial operation, and introduce more complexity on hugetlbfs code.
I don't hit on any usecase of it rather than memory failure, so I'm not
sure that it's worth doing now.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
